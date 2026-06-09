import { useState } from "react";
import SplashPolished from "./components/SplashPolished";
import SignupPolished from "./components/SignupPolished";
import EnterInfoPolished from "./components/EnterInfoPolished";
import OnboardingQ1Polished from "./components/OnboardingQ1Polished";
import OnboardingQ2Polished from "./components/OnboardingQ2Polished";
import OnboardingQ3Polished from "./components/OnboardingQ3Polished";

type Screen = "splash" | "signup" | "enter-info" | "q1" | "q2" | "q3";

export default function App() {
  const [screen, setScreen] = useState<Screen>("splash");

  return (
    <div
      className="size-full flex items-center justify-center"
      style={{ background: "linear-gradient(145deg, #DDDCFF 0%, #EEF0FF 100%)" }}
    >
      <div
        className="relative overflow-hidden rounded-[48px]"
        style={{
          width: 390,
          height: 844,
          maxWidth: "100vw",
          maxHeight: "100dvh",
          boxShadow: "0 32px 80px rgba(80,80,180,0.2), 0 4px 16px rgba(0,0,0,0.08)",
        }}
      >
        {screen === "splash" && (
          <SplashPolished onNext={() => setScreen("signup")} />
        )}
        {screen === "signup" && (
          <SignupPolished
            onCreateAccount={() => setScreen("enter-info")}
            onLogin={() => setScreen("splash")}
          />
        )}
        {screen === "enter-info" && (
          <EnterInfoPolished
            onNext={() => setScreen("q1")}
            onBack={() => setScreen("signup")}
          />
        )}
        {screen === "q1" && (
          <OnboardingQ1Polished
            onNext={() => setScreen("q2")}
            onBack={() => setScreen("enter-info")}
          />
        )}
        {screen === "q2" && (
          <OnboardingQ2Polished
            onNext={() => setScreen("q3")}
            onBack={() => setScreen("q1")}
          />
        )}
        {screen === "q3" && (
          <OnboardingQ3Polished
            onFinish={() => setScreen("splash")}
            onBack={() => setScreen("q2")}
          />
        )}
      </div>
    </div>
  );
}
