import svgPaths from "./svg-9xy70aj371";

function Frame() {
  return (
    <div className="[word-break:break-word] content-stretch flex flex-col gap-[4px] items-start relative shrink-0 text-black w-full">
      <p className="font-['Quicksand:Bold',sans-serif] font-[609] leading-[40px] relative shrink-0 text-[32px] tracking-[-0.7px] w-full">Tell us about yourself</p>
      <p className="font-['General_Sans_Variable:Medium',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[14px] w-full">We’ll use this information to personalise your experience and ensure you get suggestions suited to you.</p>
    </div>
  );
}

function Text() {
  return (
    <div className="content-stretch flex flex-[1_0_0] gap-[4px] items-center min-w-px relative" data-name="text">
      <p className="[word-break:break-word] font-['General_Sans_Variable:Medium',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#5b616d] text-[14px] text-left whitespace-nowrap">Jerry</p>
    </div>
  );
}

function InputField() {
  return (
    <div className="content-stretch flex flex-col gap-[6px] items-start relative shrink-0 w-full" data-name="input_field">
      <div className="content-stretch flex gap-[4px] items-center relative shrink-0 w-full" data-name="input_label">
        <p className="[word-break:break-word] font-['General_Sans_Variable:Regular',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#2b2930] text-[14px] text-left tracking-[0.028px] whitespace-nowrap">First, what should we call you?</p>
      </div>
      <div className="relative rounded-[12px] shrink-0 w-full" data-name="field">
        <div aria-hidden className="absolute bg-[#f4f4f6] inset-0 pointer-events-none rounded-[12px]" />
        <div className="flex flex-row items-center overflow-clip rounded-[inherit] size-full">
          <div className="content-stretch flex gap-[12px] items-center px-[16px] py-[12px] relative size-full">
            <Text />
          </div>
        </div>
        <div className="absolute inset-[-0.5px] pointer-events-none rounded-[inherit] shadow-[inset_0px_1px_3px_0px_rgba(0,0,0,0.04)]" />
        <div aria-hidden className="absolute border-[#aaa] border-[0.5px] border-solid inset-[-0.5px] pointer-events-none rounded-[12.5px]" />
      </div>
    </div>
  );
}

function Text1() {
  return (
    <div className="content-stretch flex flex-[1_0_0] gap-[4px] items-center min-w-px relative" data-name="text">
      <p className="[word-break:break-word] font-['General_Sans_Variable:Medium',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#0a0c11] text-[14px] text-left whitespace-nowrap">19</p>
    </div>
  );
}

function InputField1() {
  return (
    <div className="content-stretch flex flex-col gap-[6px] items-start relative shrink-0 w-full" data-name="input_field">
      <div className="content-stretch flex gap-[4px] items-center relative shrink-0 w-full" data-name="input_label">
        <p className="[word-break:break-word] font-['General_Sans_Variable:Regular',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#2b2930] text-[14px] text-left tracking-[0.028px] whitespace-nowrap">How old are you?</p>
      </div>
      <div className="bg-white relative rounded-[12px] shrink-0 w-full" data-name="field">
        <div className="flex flex-row items-center overflow-clip rounded-[inherit] size-full">
          <div className="content-stretch flex gap-[12px] items-center px-[16px] py-[12px] relative size-full">
            <Text1 />
          </div>
        </div>
        <div aria-hidden className="absolute border border-[#bbb3ff] border-solid inset-0 pointer-events-none rounded-[12px] shadow-[0px_0px_0px_3px_rgba(123,92,250,0.24)]" />
      </div>
    </div>
  );
}

function Text2() {
  return (
    <div className="content-stretch flex flex-[1_0_0] gap-[4px] items-center min-w-px relative" data-name="text">
      <p className="[word-break:break-word] font-['General_Sans_Variable:Medium',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#8c929c] text-[14px] text-left whitespace-nowrap">Occupation</p>
    </div>
  );
}

function InputHint() {
  return (
    <div className="content-stretch flex gap-[4px] items-center relative shrink-0 w-full" data-name="input_hint">
      <div className="overflow-clip relative shrink-0 size-[18px]" data-name="right_icon">
        <div className="absolute inset-[9.38%_9.38%_9.37%_9.37%]" data-name="Vector">
          <svg className="absolute block inset-0 size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 14.625 14.625">
            <path d={svgPaths.p2ed29580} fill="var(--fill-0, #797676)" id="Vector" />
          </svg>
        </div>
      </div>
      <p className="[word-break:break-word] font-['General_Sans_Variable:Regular',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#5b616d] text-[10px] text-left tracking-[0.2px] whitespace-nowrap">Knowing what you do helps us understand what you’re balancing</p>
    </div>
  );
}

function InputField2() {
  return (
    <button className="content-stretch cursor-pointer flex flex-col gap-[6px] items-start relative shrink-0 w-full" data-name="input_field">
      <div className="content-stretch flex gap-[4px] items-center relative shrink-0 w-full" data-name="input_label">
        <p className="[word-break:break-word] font-['General_Sans_Variable:Regular',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#2b2930] text-[14px] text-left tracking-[0.028px] whitespace-nowrap">What do you do?</p>
      </div>
      <div className="relative rounded-[12px] shrink-0 w-full" data-name="field">
        <div aria-hidden className="absolute bg-[#f4f4f6] inset-0 pointer-events-none rounded-[12px]" />
        <div className="flex flex-row items-center overflow-clip rounded-[inherit] size-full">
          <div className="content-stretch flex gap-[12px] items-center px-[16px] py-[12px] relative size-full">
            <Text2 />
          </div>
        </div>
        <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1px_3px_0px_rgba(0,0,0,0.04)]" />
      </div>
      <InputHint />
    </button>
  );
}

function Frame2() {
  return (
    <div className="content-stretch flex flex-col gap-[16px] items-start relative shrink-0 w-full">
      <button className="content-stretch cursor-pointer flex flex-col items-start relative shrink-0 w-full" data-name="input_field">
        <InputField />
      </button>
      <button className="content-stretch cursor-pointer flex flex-col items-start relative shrink-0 w-full" data-name="input_field">
        <InputField1 />
      </button>
      <div className="content-stretch flex flex-col items-start relative shrink-0 w-full" data-name="input_field">
        <InputField2 />
      </div>
    </div>
  );
}

function Frame1() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full">
      <div className="content-stretch flex h-[45px] items-center justify-center relative rounded-[8px] shrink-0 w-full" data-name="Primary-button-large">
        <div className="bg-[#7d7dde] flex-[1_0_0] h-[48px] min-w-px relative rounded-[8px]" data-name="button">
          <div className="flex flex-row items-center justify-center overflow-clip rounded-[inherit] size-full">
            <div className="content-stretch flex gap-[12px] items-center justify-center px-[16px] py-[12px] relative size-full">
              <p className="[word-break:break-word] font-['General_Sans_Variable:Medium',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[14px] text-white whitespace-nowrap">Next</p>
              <div className="overflow-clip relative shrink-0 size-[16px]" data-name="right_icon">
                <div className="absolute inset-[17.83%_12.5%_19.66%_12.5%]" data-name="Vector">
                  <svg className="absolute block inset-0 size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 12.0004 10.0006">
                    <path d={svgPaths.p342fcf00} fill="var(--fill-0, white)" id="Vector" />
                  </svg>
                </div>
              </div>
            </div>
          </div>
          <div aria-hidden className="absolute border border-[rgba(0,0,0,0.12)] border-solid inset-0 pointer-events-none rounded-[8px] shadow-[0px_1px_1px_-0.5px_rgba(0,0,0,0.04),0px_3px_3px_-1.5px_rgba(0,0,0,0.04)]" />
        </div>
      </div>
    </div>
  );
}

export default function EnterInfo() {
  return (
    <div className="bg-white content-stretch flex flex-col gap-[60px] items-center justify-center overflow-clip px-[24px] py-[80px] relative rounded-[48px] shadow-[0px_4px_8px_3px_rgba(0,0,0,0.15),0px_1px_3px_0px_rgba(0,0,0,0.3)] size-full" data-name="Enter-info">
      <Frame />
      <Frame2 />
      <Frame1 />
      <div className="absolute left-[24px] overflow-clip size-[24px] top-[64px]" data-name="arrow-left">
        <div className="absolute inset-[18.75%_12.5%]" data-name="Vector">
          <svg className="absolute block inset-0 size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 18.0006 15.0008">
            <path d={svgPaths.p33185f40} fill="var(--fill-0, black)" id="Vector" />
          </svg>
        </div>
      </div>
    </div>
  );
}