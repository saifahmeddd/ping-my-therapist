import { useState } from "react";
import svgPaths from "../../imports/OnboardingQuestion3-1/svg-gdo2inlnoi";

interface Props {
  onFinish: () => void;
  onBack: () => void;
}

export default function OnboardingQ3Polished({ onFinish, onBack }: Props) {
  const [text, setText] = useState("");

  return (
    <div className="size-full flex flex-col overflow-hidden rounded-[48px]" style={{ background: "#F7F6FF" }}>
      {/* Header */}
      <div className="px-6 pt-14 pb-6 flex-shrink-0">
        <button onClick={onBack} className="mb-6 w-9 h-9 flex items-center justify-center rounded-xl" style={{ background: "rgba(125,125,222,0.12)" }}>
          <svg width="18" height="15" fill="none" viewBox="0 0 18.0006 15.0008">
            <path d={svgPaths.p33185f40} fill="#7D7DDE" />
          </svg>
        </button>

        {/* Step progress */}
        <div className="flex gap-1.5 mb-5">
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#D5D4F8" }} />
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#D5D4F8" }} />
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#7D7DDE" }} />
        </div>

        {/* Step badge */}
        <div className="inline-flex items-center justify-center w-12 h-12 rounded-2xl mb-4" style={{ background: "#EBE9FF" }}>
          <span style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 22, color: "#7D7DDE" }}>3</span>
        </div>

        <p style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 22, letterSpacing: -0.5, lineHeight: 1.25, color: "#1A1A3A" }}>
          Anything else you'd like to tell?
        </p>
        <p style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 500, fontSize: 13, color: "#999", marginTop: 6 }}>
          Optional — skip if you prefer.
        </p>
      </div>

      {/* Textarea */}
      <div className="flex-1 px-6 overflow-auto">
        <label style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 600, fontSize: 13, color: "#555", display: "block", marginBottom: 8 }}>
          Additional Context
        </label>
        <div className="relative">
          <textarea
            value={text}
            onChange={e => setText(e.target.value)}
            placeholder="What are your likes and dislikes?"
            className="w-full rounded-2xl px-4 py-3 outline-none resize-none transition-all"
            rows={5}
            style={{
              background: "#EEEDF8",
              fontFamily: "'Quicksand', sans-serif",
              fontWeight: 500,
              fontSize: 14,
              color: "#1A1A3A",
              border: "1.5px solid transparent",
              lineHeight: 1.6,
            }}
            onFocus={e => { e.target.style.border = "1.5px solid #7D7DDE"; e.target.style.background = "white"; e.target.style.boxShadow = "0 0 0 3px rgba(125,125,222,0.15)"; }}
            onBlur={e => { e.target.style.border = "1.5px solid transparent"; e.target.style.background = "#EEEDF8"; e.target.style.boxShadow = "none"; }}
          />
          {/* Resizer icon in corner */}
          <div className="absolute bottom-2 right-2 pointer-events-none opacity-40">
            <svg width="16" height="16" fill="none" viewBox="0 0 20 20">
              <path clipRule="evenodd" d={svgPaths.p198b7400} fill="#7D7DDE" fillRule="evenodd" />
              <path clipRule="evenodd" d={svgPaths.p3bbc1c80} fill="#7D7DDE" fillRule="evenodd" />
            </svg>
          </div>
        </div>

        {/* Character hint */}
        <p className="mt-2" style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 500, fontSize: 11, color: "#BBB" }}>
          Share anything that helps us understand you better
        </p>
      </div>

      {/* CTA */}
      <div className="px-6 pb-10 pt-4 flex-shrink-0">
        <button
          onClick={onFinish}
          className="w-full h-[54px] rounded-2xl flex items-center justify-center gap-3 transition-all active:scale-[0.98]"
          style={{
            background: "#7D7DDE",
            boxShadow: "0 8px 24px rgba(125,125,222,0.4)",
          }}
        >
          <span style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 16, color: "white", letterSpacing: -0.2 }}>Finish</span>
          <svg width="14" height="12" fill="none" viewBox="0 0 12.5006 9.00039">
            <path d={svgPaths.p289cf000} fill="white" />
          </svg>
        </button>
      </div>
    </div>
  );
}
