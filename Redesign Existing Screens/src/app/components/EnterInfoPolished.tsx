import { useState } from "react";
import svgPaths from "../../imports/EnterInfo-1/svg-9xy70aj371";

interface Props {
  onNext: () => void;
  onBack: () => void;
}

export default function EnterInfoPolished({ onNext, onBack }: Props) {
  const [name, setName] = useState("Jerry");
  const [age, setAge] = useState("19");
  const [occupation, setOccupation] = useState("");

  return (
    <div className="size-full flex flex-col overflow-hidden rounded-[48px]" style={{ background: "#F7F6FF" }}>
      {/* Header */}
      <div className="px-6 pt-14 pb-6 flex-shrink-0">
        <button onClick={onBack} className="mb-6 w-9 h-9 flex items-center justify-center rounded-xl" style={{ background: "rgba(125,125,222,0.12)" }}>
          <svg width="18" height="15" fill="none" viewBox="0 0 18.0006 15.0008">
            <path d={svgPaths.p33185f40} fill="#7D7DDE" />
          </svg>
        </button>

        {/* Step indicator */}
        <div className="flex gap-1.5 mb-5">
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#7D7DDE" }} />
          <div className="h-1.5 w-2 rounded-full" style={{ background: "#D5D4F8" }} />
          <div className="h-1.5 w-2 rounded-full" style={{ background: "#D5D4F8" }} />
          <div className="h-1.5 w-2 rounded-full" style={{ background: "#D5D4F8" }} />
        </div>

        <p style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 26, letterSpacing: -0.6, lineHeight: 1.2, color: "#1A1A3A" }}>
          Tell us about yourself
        </p>
        <p style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 500, fontSize: 13, color: "#888", marginTop: 6, lineHeight: 1.5 }}>
          We'll personalise your experience to suit you.
        </p>
      </div>

      {/* Form */}
      <div className="flex-1 px-6 flex flex-col gap-4 overflow-auto">
        {/* Name field */}
        <div className="flex flex-col gap-1.5">
          <label style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 600, fontSize: 13, color: "#555" }}>
            What should we call you?
          </label>
          <div className="relative">
            <input
              value={name}
              onChange={e => setName(e.target.value)}
              className="w-full h-12 px-4 rounded-2xl outline-none transition-all"
              style={{
                background: "#EEEDF8",
                fontFamily: "'Quicksand', sans-serif",
                fontWeight: 600,
                fontSize: 15,
                color: "#1A1A3A",
                border: "1.5px solid transparent",
              }}
              onFocus={e => { e.target.style.border = "1.5px solid #7D7DDE"; e.target.style.background = "white"; e.target.style.boxShadow = "0 0 0 3px rgba(125,125,222,0.15)"; }}
              onBlur={e => { e.target.style.border = "1.5px solid transparent"; e.target.style.background = "#EEEDF8"; e.target.style.boxShadow = "none"; }}
            />
          </div>
        </div>

        {/* Age field — shown as focused/active */}
        <div className="flex flex-col gap-1.5">
          <label style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 600, fontSize: 13, color: "#555" }}>
            How old are you?
          </label>
          <input
            value={age}
            onChange={e => setAge(e.target.value)}
            type="number"
            className="w-full h-12 px-4 rounded-2xl outline-none transition-all"
            style={{
              background: "white",
              fontFamily: "'Quicksand', sans-serif",
              fontWeight: 600,
              fontSize: 15,
              color: "#1A1A3A",
              border: "1.5px solid #7D7DDE",
              boxShadow: "0 0 0 3px rgba(125,125,222,0.15)",
            }}
            onFocus={e => { e.target.style.border = "1.5px solid #7D7DDE"; e.target.style.background = "white"; e.target.style.boxShadow = "0 0 0 3px rgba(125,125,222,0.15)"; }}
            onBlur={e => { e.target.style.border = "1.5px solid transparent"; e.target.style.background = "#EEEDF8"; e.target.style.boxShadow = "none"; }}
          />
        </div>

        {/* Occupation field */}
        <div className="flex flex-col gap-1.5">
          <label style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 600, fontSize: 13, color: "#555" }}>
            What do you do?
          </label>
          <input
            value={occupation}
            onChange={e => setOccupation(e.target.value)}
            placeholder="Occupation"
            className="w-full h-12 px-4 rounded-2xl outline-none transition-all"
            style={{
              background: "#EEEDF8",
              fontFamily: "'Quicksand', sans-serif",
              fontWeight: 600,
              fontSize: 15,
              color: "#1A1A3A",
              border: "1.5px solid transparent",
            }}
            onFocus={e => { e.target.style.border = "1.5px solid #7D7DDE"; e.target.style.background = "white"; e.target.style.boxShadow = "0 0 0 3px rgba(125,125,222,0.15)"; }}
            onBlur={e => { e.target.style.border = "1.5px solid transparent"; e.target.style.background = "#EEEDF8"; e.target.style.boxShadow = "none"; }}
          />
          <div className="flex items-center gap-1.5 mt-0.5">
            <svg width="14" height="14" fill="none" viewBox="0 0 14.625 14.625">
              <path d={svgPaths.p2ed29580} fill="#AAA" />
            </svg>
            <p style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 500, fontSize: 11, color: "#AAA" }}>
              Helps us understand what you're balancing
            </p>
          </div>
        </div>
      </div>

      {/* CTA */}
      <div className="px-6 pb-10 pt-4 flex-shrink-0">
        <button
          onClick={onNext}
          className="w-full h-[54px] rounded-2xl flex items-center justify-center gap-3 transition-all active:scale-[0.98]"
          style={{
            background: "#7D7DDE",
            boxShadow: "0 8px 24px rgba(125,125,222,0.4)",
          }}
        >
          <span style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 16, color: "white", letterSpacing: -0.2 }}>Next</span>
          <svg width="14" height="12" fill="none" viewBox="0 0 12.0004 10.0006">
            <path d={svgPaths.p342fcf00} fill="white" />
          </svg>
        </button>
      </div>
    </div>
  );
}
