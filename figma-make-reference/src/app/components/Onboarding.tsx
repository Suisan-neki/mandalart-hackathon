import { useState } from "react";
import { useNavigate } from "react-router";
import { motion, AnimatePresence } from "motion/react";
import { LayoutGrid, Layers, Flame, ChevronRight, Activity } from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const slides = [
  {
    type: "image",
    imageUrl: "https://images.unsplash.com/photo-1774976723145-cb535cd4aee8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiYXNlYmFsbCUyMHBsYXllciUyMHNpbGhvdWV0dGUlMjBzdGFkaXVtfGVufDF8fHx8MTc3NjE0ODA3OHww&ixlib=rb-4.1.0&q=80&w=1080",
    title: "マンダラートの力",
    subtitle: "思考を整理し、夢を現実にする",
    desc: "マンダラートとは、目標達成のための最強の思考整理ツールです。あの大谷翔平選手も高校時代に作成し、見事夢を実現したことで知られています。あなたも、思考を視覚化して不可能を可能にしましょう。",
    theme: "text-blue-400",
    indicator: "bg-blue-500",
  },
  {
    type: "icon",
    icon: <LayoutGrid className="w-24 h-24 text-orange-500 mb-8" />,
    title: "従来の課題と革新",
    subtitle: "スマホ時代のマンダラートへ",
    desc: "「81マスはスマホでは全体が見えないし、入力も面倒…」そんな従来の課題を解決するため、本アプリでは16〜32項目に凝縮。スマートフォンでの一覧性と操作性を極限まで高めました。",
    theme: "text-orange-500",
    indicator: "bg-orange-500",
  },
  {
    type: "icon",
    icon: <Layers className="w-24 h-24 text-green-500 mb-8" />,
    title: "モバイルファーストな再構築",
    subtitle: "伝統を打ち破る直感的なデザイン",
    desc: "私たちは伝統的なマス目の形に固執せず、あなたのスマホで最も使いやすく、直感的に操作できる「カード型UI」を追求しました。これがあなたの目標達成を最速でサポートする形です。",
    theme: "text-green-500",
    indicator: "bg-green-500",
  },
  {
    type: "icon",
    icon: <Activity className="w-24 h-24 text-amber-500 mb-8" />,
    title: "目標と現実の同期",
    subtitle: "日々の行動をやさしく記録する",
    desc: "高い目標を持つからこそ、目標と現実のギャップに悩むことがあります。Mandalart Syncはあなたの自己認識を尊重し、優しく寄り添いながら行動と目標のすり合わせをサポートします。",
    theme: "text-amber-500",
    indicator: "bg-amber-500",
  }
];

export function Onboarding() {
  const [currentSlide, setCurrentSlide] = useState(0);
  const navigate = useNavigate();

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(currentSlide + 1);
    } else {
      navigate("/integrations");
    }
  };

  const handleSkip = () => {
    navigate("/integrations");
  };

  const slide = slides[currentSlide];

  return (
    <div className="flex h-full w-full flex-col bg-zinc-950 text-white font-sans relative overflow-hidden">
      <div className="absolute top-16 right-6 z-50">
        <button onClick={handleSkip} className="text-white/50 text-xs font-bold tracking-widest uppercase hover:text-white transition-colors">
          Skip
        </button>
      </div>

      <div className="flex-1 relative">
        <AnimatePresence mode="wait">
          {slide.type === "image" ? (
            <motion.div
              key={`slide-img-${currentSlide}`}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.8 }}
              className="absolute inset-0"
            >
              <div 
                className="absolute inset-0 bg-cover bg-center" 
                style={{ backgroundImage: `url(${slide.imageUrl})` }}
              />
              <div className="absolute inset-0 bg-gradient-to-b from-zinc-950/20 via-zinc-950/80 to-zinc-950" />
            </motion.div>
          ) : (
            <motion.div
              key={`slide-bg-${currentSlide}`}
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.5 }}
              className="absolute inset-0 flex items-center justify-center pointer-events-none"
            >
               <div className={cn("w-96 h-96 blur-[120px] rounded-full opacity-20", slide.indicator)} />
            </motion.div>
          )}
        </AnimatePresence>

        <div className="absolute inset-0 flex flex-col justify-end p-8 pb-32">
          <AnimatePresence mode="wait">
            <motion.div
              key={`slide-content-${currentSlide}`}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -30 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="flex flex-col h-full justify-end"
            >
              {slide.type === "icon" ? (
                <div className="flex-1 flex items-end justify-center pb-12 w-full">
                  <motion.div
                    initial={{ scale: 0.8, rotate: -10 }}
                    animate={{ scale: 1, rotate: 0 }}
                    transition={{ type: "spring", stiffness: 200, damping: 20 }}
                  >
                    {slide.icon}
                  </motion.div>
                </div>
              ) : (
                <div className="flex-1 w-full" />
              )}

              <div className="mt-auto w-full">
                <h3 className={cn("text-xs font-black tracking-widest uppercase mb-3", slide.theme)}>
                  {slide.subtitle}
                </h3>
                <h2 className="text-3xl font-black mb-6 leading-tight text-white drop-shadow-md">
                  {slide.title}
                </h2>
                <p className="text-zinc-400 text-sm leading-relaxed mb-8 drop-shadow max-w-sm">
                  {slide.desc}
                </p>
              </div>
            </motion.div>
          </AnimatePresence>
        </div>
      </div>

      <div className="absolute bottom-0 left-0 w-full p-8 flex flex-col gap-8 z-20">
        <div className="flex gap-2">
          {slides.map((s, i) => (
            <div
              key={i}
              className={cn(
                "h-1.5 rounded-full transition-all duration-500",
                i === currentSlide ? cn("w-8", s.indicator) : "w-2 bg-white/20"
              )}
            />
          ))}
        </div>
        
        <button
          onClick={handleNext}
          className="w-full h-14 bg-white text-black font-bold rounded-2xl flex items-center justify-center gap-2 transition-transform active:scale-95 shadow-[0_0_30px_rgba(255,255,255,0.1)] hover:bg-zinc-100"
        >
          {currentSlide === slides.length - 1 ? (
            <span className="flex items-center gap-2">覚悟を決めて始める <Flame className="w-5 h-5 text-red-600" /></span>
          ) : (
            <span className="flex items-center gap-2">次へ <ChevronRight className="w-5 h-5" /></span>
          )}
        </button>
      </div>
    </div>
  );
}