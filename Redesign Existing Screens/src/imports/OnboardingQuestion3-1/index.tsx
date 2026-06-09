import svgPaths from "./svg-gdo2inlnoi";

function Frame2() {
  return (
    <div className="bg-[#e5e5f8] content-stretch flex flex-col items-center justify-center px-[24px] py-[20px] relative rounded-[50px] shrink-0 size-[64px]">
      <p className="[word-break:break-word] font-['Quicksand:Bold',sans-serif] font-[609] leading-[40px] relative shrink-0 text-[32px] text-black tracking-[-0.7px] whitespace-nowrap">3</p>
    </div>
  );
}

function Frame() {
  return (
    <div className="content-stretch flex flex-col items-start relative shrink-0 w-full">
      <p className="[word-break:break-word] font-['Quicksand:SemiBold',sans-serif] font-semibold leading-[1.2] relative shrink-0 text-[24px] text-black tracking-[-0.5px] w-full">Anything else you’d like to tell?</p>
    </div>
  );
}

function Frame3() {
  return (
    <div className="content-stretch flex flex-col gap-[24px] items-start relative shrink-0 w-full">
      <Frame2 />
      <Frame />
    </div>
  );
}

function Text() {
  return (
    <div className="content-stretch flex flex-[1_0_0] items-center min-w-px relative" data-name="text">
      <p className="[word-break:break-word] font-['General_Sans_Variable:Regular',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#8c929c] text-[12px] text-left tracking-[0.06px] whitespace-nowrap">What are your likes and dislikes?</p>
    </div>
  );
}

function IconResizer() {
  return (
    <div className="absolute bottom-0 right-0 size-[20px]" data-name="icon / resizer">
      <svg className="absolute block inset-0 size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 20 20">
        <g id="icon / resizer">
          <g id="Vector">
            <path clipRule="evenodd" d={svgPaths.p198b7400} fill="var(--fill-0, #C3C6CC)" fillRule="evenodd" />
            <path clipRule="evenodd" d={svgPaths.p3bbc1c80} fill="var(--fill-0, #C3C6CC)" fillRule="evenodd" />
          </g>
        </g>
      </svg>
    </div>
  );
}

function InputField() {
  return (
    <div className="content-stretch flex flex-col gap-[6px] items-start relative shrink-0 w-full" data-name="input_field">
      <div className="content-stretch flex gap-[4px] items-center relative shrink-0 w-full" data-name="input_label">
        <p className="[word-break:break-word] font-['General_Sans_Variable:Regular',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[#2b2930] text-[14px] text-left tracking-[0.028px] whitespace-nowrap">Additional Context</p>
      </div>
      <div className="h-[104px] relative rounded-[10px] shrink-0 w-full" data-name="field">
        <div aria-hidden className="absolute bg-[#f4f4f6] inset-0 pointer-events-none rounded-[10px]" />
        <div className="overflow-clip rounded-[inherit] size-full">
          <div className="content-stretch flex gap-[12px] items-start px-[16px] py-[12px] relative size-full">
            <Text />
            <IconResizer />
          </div>
        </div>
        <div className="absolute inset-0 pointer-events-none rounded-[inherit] shadow-[inset_0px_1px_3px_0px_rgba(0,0,0,0.04)]" />
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
              <p className="[word-break:break-word] font-['General_Sans_Variable:Medium',sans-serif] leading-[1.5] not-italic relative shrink-0 text-[14px] text-white whitespace-nowrap">Finish</p>
              <div className="overflow-clip relative shrink-0 size-[16px]" data-name="right_icon">
                <div className="absolute bottom-[18.75%] left-[12.5%] right-[9.37%] top-1/4" data-name="Vector">
                  <svg className="absolute block inset-0 size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 12.5006 9.00039">
                    <path d={svgPaths.p289cf000} fill="var(--fill-0, white)" id="Vector" />
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

export default function OnboardingQuestion() {
  return (
    <div className="bg-white content-stretch flex flex-col gap-[60px] items-center justify-center overflow-clip px-[24px] py-[80px] relative rounded-[48px] shadow-[0px_4px_8px_3px_rgba(0,0,0,0.15),0px_1px_3px_0px_rgba(0,0,0,0.3)] size-full" data-name="Onboarding Question 3">
      <Frame3 />
      <button className="content-stretch cursor-pointer flex flex-col items-start relative shrink-0 w-full" data-name="text_box">
        <InputField />
      </button>
      <Frame1 />
      <a className="absolute block cursor-pointer left-[24px] overflow-clip size-[24px] top-[64px]" data-name="arrow-left">
        <div className="absolute inset-[18.75%_12.5%]" data-name="Vector">
          <svg className="absolute block inset-0 size-full" fill="none" preserveAspectRatio="none" viewBox="0 0 18.0006 15.0008">
            <path d={svgPaths.p33185f40} fill="var(--fill-0, black)" id="Vector" />
          </svg>
        </div>
      </a>
    </div>
  );
}