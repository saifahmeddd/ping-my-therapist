import { useState } from "react";
import svgPaths from "../../imports/OnboardingQuestion1-1/svg-2jreerskmu";

interface Props {
  onNext: () => void;
  onBack: () => void;
}

const OPTIONS = ["Reflect quietly", "Reach out", "Power through", "Distract yourself"];

export default function OnboardingQ1Polished({ onNext, onBack }: Props) {
  const [selected, setSelected] = useState(0);

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
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#7D7DDE" }} />
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#D5D4F8" }} />
          <div className="h-1.5 w-6 rounded-full" style={{ background: "#D5D4F8" }} />
        </div>

        {/* Step badge */}
        <div className="inline-flex items-center justify-center w-12 h-12 rounded-2xl mb-4" style={{ background: "#EBE9FF" }}>
          <span style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 22, color: "#7D7DDE" }}>1</span>
        </div>

        <p style={{ fontFamily: "'Quicksand', sans-serif", fontWeight: 700, fontSize: 22, letterSpacing: -0.5, lineHeight: 1.25, color: "#1A1A3A" }}>
          When life gets overwhelming, you usually...
        </p>
      </div>

      {/* Options */}
      <div className="flex-1 px-6 flex flex-col gap-3 overflow-auto">
        {OPTIONS.map((option, i) => {
          const isSelected = selected === i;
          return (
            <button
              key={option}
              onClick={() => setSelected(i)}
              className="w-full h-[52px] px-4 rounded-2xl flex items-center gap-3 transition-all active:scale-[0.98]"
              style={{
                background: isSelected ? "#7D7DDE" : "white",
                border: isSelected ? "2px solid #9393E3" : "1.5px solid #E8E6F8",
                boxShadow: isSelected ? "0 4px 16px rgba(125,125,222,0.3)" : "0 1px 4px rgba(0,0,0,0.04)",
              }}
            >
              {/* Icon */}
              <div className="flex-shrink-0 w-5 h-5 flex items-center justify-center">
                {isSelected ? (
                  <svg width="16" height="12" fill="none" viewBox="0 0 15.6257 11.2505">
                    <path d={svgPaths.p3a3fe300} fill="white" />
                  </svg>
                ) : (
                  <div className="w-4 h-4 rounded-full" style={{ background: "#D5D4F8" }} />
                )}
              </div>
              <span style={{
                fontFamily: "'Quicksand', sans-serif",
                fontWeight: 600,
                fontSize: 15,
                color: isSelected ? "white" : "#1A1A3A",
              }}>
                {option}
              </span>
            </button>
          );
        })}
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
