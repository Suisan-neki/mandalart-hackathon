import { useState } from "react";
import { useNavigate } from "react-router";
import { motion, AnimatePresence } from "motion/react";
import { Check, ChevronRight, Target, LayoutGrid } from "lucide-react";

export function MandalartInput() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);
  const [mainGoal, setMainGoal] = useState("");
  const [subGoals, setSubGoals] = useState(["", "", "", ""]);

  const isStep1Complete = mainGoal.trim() !== "";
  const isStep2Complete = subGoals.every((sg) => sg.trim() !== "");

  const handleNext = () => {
    if (step === 1 && isStep1Complete) setStep(2);
    else if (step === 2 && isStep2Complete) navigate("/app/home");
  };

  return (
    <div className="flex h-full w-full flex-col bg-zinc-950 text-white font-sans relative overflow-hidden">
      <div className="px-6 pt-16 pb-6">
        <h1 className="text-2xl font-black mb-2 flex items-center gap-2">
          <LayoutGrid className="w-6 h-6 text-red-600" />
          マンダラートの構築
        </h1>
        <div className="flex gap-2 mb-8">
          <div className={`h-1 flex-1 rounded-full transition-colors ${step >= 1 ? "bg-red-600" : "bg-zinc-800"}`} />
          <div className={`h-1 flex-1 rounded-full transition-colors ${step >= 2 ? "bg-red-600" : "bg-zinc-800"}`} />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-6 pb-24">
        <AnimatePresence mode="wait">
          {step === 1 && (
            <motion.div
              key="step1"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="space-y-6"
            >
              <div>
                <h2 className="text-sm font-bold text-zinc-400 mb-1 tracking-widest uppercase">Step 1</h2>
                <h3 className="text-xl font-bold mb-4">究極の目的（メインテーマ）は？</h3>
                <p className="text-xs text-zinc-500 mb-6 leading-relaxed">
                  あなたが達成したい、最も大きな目標を1つ設定してください。これがすべての行動の軸になります。
                </p>
              </div>

              <div className="relative">
                <div className="absolute -inset-1 bg-red-600/20 blur-xl rounded-[32px] pointer-events-none" />
                <div className="bg-zinc-900 border border-red-500/30 rounded-[32px] p-6 relative">
                  <Target className="w-8 h-8 text-red-500 mb-4 opacity-50" />
                  <textarea
                    value={mainGoal}
                    onChange={(e) => setMainGoal(e.target.value)}
                    placeholder="例：最強のエンジニアになる"
                    className="w-full bg-transparent text-white text-2xl font-black tracking-tight placeholder:text-zinc-700 focus:outline-none resize-none h-32"
                    autoFocus
                  />
                </div>
              </div>
            </motion.div>
          )}

          {step === 2 && (
            <motion.div
              key="step2"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              className="space-y-6"
            >
              <div>
                <h2 className="text-sm font-bold text-zinc-400 mb-1 tracking-widest uppercase">Step 2</h2>
                <h3 className="text-xl font-bold mb-4">目的を構成する4つの要素</h3>
                <p className="text-xs text-zinc-500 mb-6 leading-relaxed">
                  「{mainGoal}」を達成するために必要なサブテーマを4つ設定してください。
                </p>
              </div>

              <div className="space-y-4">
                {subGoals.map((sg, idx) => (
                  <div key={idx} className="bg-zinc-900 border border-zinc-800 rounded-2xl p-4 flex items-center gap-4 focus-within:border-red-500/50 transition-colors">
                    <div className="w-8 h-8 rounded-full bg-zinc-800 text-zinc-400 flex items-center justify-center font-bold font-mono text-sm">
                      {idx + 1}
                    </div>
                    <input
                      value={sg}
                      onChange={(e) => {
                        const newSg = [...subGoals];
                        newSg[idx] = e.target.value;
                        setSubGoals(newSg);
                      }}
                      placeholder={`サブテーマ ${idx + 1}`}
                      className="flex-1 bg-transparent text-white font-bold placeholder:text-zinc-700 focus:outline-none"
                    />
                  </div>
                ))}
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

      <div className="absolute bottom-0 left-0 w-full p-6 bg-gradient-to-t from-zinc-950 via-zinc-950 to-transparent">
        <motion.button
          whileTap={((step === 1 && isStep1Complete) || (step === 2 && isStep2Complete)) ? { scale: 0.95 } : {}}
          onClick={handleNext}
          disabled={step === 1 ? !isStep1Complete : !isStep2Complete}
          className={`w-full h-14 font-bold rounded-2xl flex items-center justify-center gap-2 transition-all duration-300 ${
            (step === 1 && isStep1Complete) || (step === 2 && isStep2Complete)
              ? "bg-white text-black shadow-[0_0_20px_rgba(255,255,255,0.2)]"
              : "bg-zinc-800 text-zinc-500 cursor-not-allowed"
          }`}
        >
          {step === 2 ? (
            <>
              <Check className="w-5 h-5" /> 構築を完了する
            </>
          ) : (
            <>
              次へ <ChevronRight className="w-5 h-5" />
            </>
          )}
        </motion.button>
      </div>
    </div>
  );
}
