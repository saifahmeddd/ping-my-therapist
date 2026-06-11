/**
 * chatWithMoody — Firebase Callable Function
 *
 * SETUP INSTRUCTIONS
 * ──────────────────
 * 1. Install the Firebase CLI:
 *      npm install -g firebase-tools
 *
 * 2. Log in:
 *      firebase login
 *
 * 3. Set the Groq API key in Firebase Secret Manager:
 *      firebase functions:secrets:set GROQ_API_KEY
 *      (paste your key when prompted — it is never stored in code)
 *
 *    If you prefer environment config instead:
 *      firebase functions:config:set groq.api_key="gsk_..."
 *    Then change the secret block below to:
 *      const apiKey = process.env.GROQ_API_KEY
 *                  || functions.config().groq?.api_key;
 *
 * 4. Deploy:
 *      cd /path/to/project
 *      firebase deploy --only functions
 *
 * 5. First deploy may ask you to enable the Secret Manager API in GCP Console.
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { logger } = require("firebase-functions");

const GROQ_API_KEY = defineSecret("GROQ_API_KEY");

// ─── Constants ────────────────────────────────────────────────────────────────

const GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
const GROQ_MODEL = "llama-3.1-8b-instant";

const SYSTEM_PROMPT = `You are Moody, a warm and supportive mental-health companion inside the "Ping My Therapist" app.

Your role:
- Offer empathetic, short (2–4 sentences), practical emotional support.
- Listen actively and validate the user's feelings before suggesting anything.
- Suggest coping techniques when appropriate: box breathing, grounding (5-4-3-2-1), journaling, talking to a trusted person, or gentle movement.
- Use simple, conversational language. No jargon. No emojis.

Hard limits:
- Do NOT diagnose any condition.
- Do NOT recommend or mention any medication.
- Do NOT claim to be a therapist or replace professional mental health care.
- If the user mentions self-harm, suicide, abuse, or immediate danger, respond ONLY with the crisis message — do not engage further in that turn.

Tone: Calm, caring, non-judgmental, and grounded. Like a wise friend who genuinely listens.`;

/**
 * Crisis keywords — detected before calling Groq.
 * Kept deliberately broad to minimise false negatives.
 */
const CRISIS_PATTERNS = [
  /\bsuicid(e|al|ally)\b/i,
  /\bkill\s+my\s*self\b/i,
  /\bend\s+(my|this)\s+life\b/i,
  /\bself[\s-]?harm\b/i,
  /\bcut(ting)?\s+(my|myself)\b/i,
  /\bwant\s+to\s+die\b/i,
  /\bdon'?t\s+want\s+to\s+(live|be\s+alive)\b/i,
  /\bhurt(ing)?\s+(my|myself)\b/i,
  /\babuse\b/i,
  /\brapid?\b/i,
  /\bsexual[\s-]?assault\b/i,
  /\bdomestic[\s-]?violence\b/i,
  /\bin\s+(immediate|danger)\b/i,
  /\bemergency\b/i,
  /\boverdos(e|ing)\b/i,
  /\bno\s+reason\s+to\s+live\b/i,
  /\bbetter\s+off\s+(dead|without\s+me)\b/i,
];

const CRISIS_REPLY = `I hear you, and I want you to know you're not alone. What you're feeling matters deeply.

Please reach out to a crisis line right now — they are trained to help:
• Pakistan: Umang helpline 0317-4288665 (24/7)
• International: Crisis Text Line — text HOME to 741741
• Worldwide directory: findahelpline.com

If you are in immediate danger, please call emergency services (1122 / 115 / local emergency number) or go to the nearest hospital.

You deserve support. Please talk to someone you trust or a professional today.`;

// ─── Risk-level helper ────────────────────────────────────────────────────────

/**
 * Returns a simple risk level string based on message content.
 * "crisis" is caught before Groq; this is for moderate signals.
 */
function assessRiskLevel(message) {
  if (CRISIS_PATTERNS.some((re) => re.test(message))) return "crisis";
  const moderatePatterns = [
    /\bhopeless\b/i,
    /\bworthless\b/i,
    /\bcan'?t\s+go\s+on\b/i,
    /\btrapped\b/i,
    /\bnumb\b/i,
    /\bexhausted\b/i,
    /\bbreakdown\b/i,
    /\banxiet(y|ies)\b/i,
    /\bdepressed\b/i,
  ];
  if (moderatePatterns.some((re) => re.test(message))) return "moderate";
  return "low";
}

// ─── Callable function ────────────────────────────────────────────────────────

exports.chatWithMoody = onCall(
  {
    secrets: [GROQ_API_KEY],
    region: "us-central1",
    timeoutSeconds: 30,
    memory: "256MiB",
  },
  async (request) => {
    // ── 1. Auth check ────────────────────────────────────────────────────────
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to use Moody."
      );
    }

    const { message, history = [] } = request.data;

    // ── 2. Input validation ──────────────────────────────────────────────────
    if (!message || typeof message !== "string" || message.trim().length === 0) {
      throw new HttpsError("invalid-argument", "message must be a non-empty string.");
    }

    const trimmedMessage = message.trim().slice(0, 2000);

    // ── 3. Crisis detection (before calling Groq) ────────────────────────────
    const riskLevel = assessRiskLevel(trimmedMessage);

    if (riskLevel === "crisis") {
      logger.info("Crisis message detected", {
        uid: request.auth.uid,
        riskLevel,
      });
      return {
        reply: CRISIS_REPLY,
        riskLevel: "crisis",
        timestamp: new Date().toISOString(),
      };
    }

    // ── 4. Build message array for Groq ──────────────────────────────────────
    const maxHistory = 16; // keep last 8 turns (user+assistant pairs)
    const trimmedHistory = Array.isArray(history)
      ? history.slice(-maxHistory)
      : [];

    const messages = [
      { role: "system", content: SYSTEM_PROMPT },
      ...trimmedHistory
        .filter(
          (m) =>
            m &&
            typeof m.role === "string" &&
            typeof m.content === "string" &&
            ["user", "assistant"].includes(m.role)
        )
        .map((m) => ({ role: m.role, content: m.content.slice(0, 1000) })),
      { role: "user", content: trimmedMessage },
    ];

    // ── 5. Call Groq ─────────────────────────────────────────────────────────
    const apiKey = GROQ_API_KEY.value();

    let groqResponse;
    try {
      groqResponse = await fetch(GROQ_API_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model: GROQ_MODEL,
          messages,
          max_tokens: 300,
          temperature: 0.65,
          stop: null,
        }),
      });
    } catch (networkErr) {
      logger.error("Groq network error", networkErr);
      throw new HttpsError("internal", "Could not reach the AI service. Please try again.");
    }

    if (!groqResponse.ok) {
      const errorText = await groqResponse.text().catch(() => "");
      logger.error("Groq API error", {
        status: groqResponse.status,
        body: errorText,
      });
      throw new HttpsError(
        "internal",
        "The AI service returned an error. Please try again."
      );
    }

    const groqData = await groqResponse.json();
    const reply =
      groqData?.choices?.[0]?.message?.content?.trim() ??
      "I'm here for you. Could you tell me a little more about what's on your mind?";

    // ── 6. Return structured response ────────────────────────────────────────
    return {
      reply,
      riskLevel,
      timestamp: new Date().toISOString(),
    };
  }
);
