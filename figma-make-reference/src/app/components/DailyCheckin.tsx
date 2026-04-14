import { useState } from "react";
import { useNavigate } from "react-router";
import { motion, AnimatePresence, useMotionValue, useTransform } from "motion/react";
import { Check, X, ArrowLeft, Zap, Target } from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

type ColorTheme = "blue" | "orange" | "green" | "purple";

const colorMap = {
  blue: { bgActive: "rgba(59,130,246,1)", bgLight: "rgba(59,130,246,0.1)", text: "text-blue-500", border: "border-blue-200" },
  orange: { bgActive: "rgba(249,115,22,1)", bgLight: "rgba(249,115,22,0.1)", text: "text-orange-500", border: "border-orange-200" },
  green: { bgActive: "rgba(34,197,94,1)", bgLight: "rgba(34,197,94,0.1)", text: "text-green-500", border: "border-green-200" },
  purple: { bgActive: "rgba(168,85,247,1)", bgLight: "rgba(168,85,247,0.1)", text: "text-purple-500", border: "border-purple-200" },
};

const tasks = [
  { id: 1, title: "1日1時間のコーディング", category: "技術力", theme: "blue" as ColorTheme },
  { id: 2, title: "OSSにPRを出す", category: "技術力", theme: "blue" as ColorTheme },
  { id: 3, title: "週1回ブログ更新", category: "発信力", theme: "orange" as ColorTheme },
  { id: 4, title: "Twitterで毎日発信", category: "発信力", theme: "orange" as ColorTheme },
  { id: 5, title: "週3回の筋トレ", category: "健康", theme: "green" as ColorTheme },
  { id: 6, title: "他者と比較しない", category: "マインド", theme: "purple" as ColorTheme },
];

export function DailyCheckin() {
  const navigate = useNavigate();
  const [cards, setCards] = useState(tasks);
  const [direction, setDirection] = useState<"left" | "right" | null>(null);

  const activeIndex = cards.length - 1;

  const handleSwipe = (dir: "left" | "right") => {
    setDirection(dir);
    setTimeout(() => {
      setCards((prev) => prev.slice(0, -1));
      setDirection(null);
    }, 200); // Wait for exit animation
  };

  if (cards.length === 0) {
    return (
      <div className="flex flex-col h-full w-full bg-amber-50 text-stone-900 items-center justify-center p-6 text-center font-sans">
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          className="flex flex-col items-center"
        >
          <div className="w-24 h-24 rounded-full bg-amber-200/50 text-amber-600 flex items-center justify-center mb-6 shadow-sm">
            <Check className="w-12 h-12" />
          </div>
          <h2 className="text-2xl font-black text-stone-800 mb-2">チェックイン完了</h2>
          <p className="text-stone-500 text-sm mb-12">今日の振り返りが記録されました。<br/>実際のログと同期（Sync）しています…</p>
          
          <button
            onClick={() => navigate("/app/result")}
            className="w-full max-w-xs py-4 bg-amber-500 text-white font-bold rounded-2xl flex items-center justify-center gap-2 hover:bg-amber-600 transition-colors shadow-lg shadow-amber-500/20"
          >
            同期結果を見る <Zap className="w-5 h-5 text-amber-100" />
          </button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-hidden relative font-sans">
      <div className="flex items-center justify-between p-6 pt-16">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-200 transition-colors">
          <ArrowLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="flex items-center gap-2 font-bold text-stone-800 tracking-tight">
          <Target className="w-5 h-5 text-red-600" />
          デイリーチェックイン
        </div>
        <div className="w-10 text-right text-stone-400 font-mono font-bold">
          {tasks.length - cards.length + 1}/{tasks.length}
        </div>
      </div>

      <div className="px-6 mb-4">
        <div className="w-full h-1 bg-stone-200 rounded-full overflow-hidden">
          <motion.div 
            className="h-full bg-red-600"
            initial={{ width: 0 }}
            animate={{ width: `${((tasks.length - cards.length) / tasks.length) * 100}%` }}
          />
        </div>
      </div>

      <div className="flex-1 relative flex items-center justify-center p-6">
        <AnimatePresence>
          {cards.map((card, index) => {
            if (index < activeIndex - 1) return null; // Show top two cards
            const isTop = index === activeIndex;

            return (
              <SwipeableCard
                key={card.id}
                card={card}
                isTop={isTop}
                direction={direction}
                onSwipe={handleSwipe}
              />
            );
          })}
        </AnimatePresence>
      </div>

      <div className="flex justify-center gap-6 p-10 pb-20 z-10">
        <button
          onClick={() => handleSwipe("left")}
          className="w-16 h-16 rounded-full bg-white shadow-xl border border-stone-200 flex items-center justify-center text-stone-400 hover:bg-red-50 hover:text-red-500 hover:border-red-200 transition-colors group active:scale-95"
        >
          <X className="w-8 h-8 transition-transform" />
        </button>
        <button
          onClick={() => handleSwipe("right")}
          className="w-16 h-16 rounded-full bg-white shadow-xl border border-stone-200 flex items-center justify-center text-green-500 hover:bg-green-50 hover:border-green-200 transition-colors group active:scale-95"
        >
          <Check className="w-8 h-8 transition-transform" />
        </button>
      </div>
    </div>
  );
}

function SwipeableCard({ card, isTop, direction, onSwipe }: any) {
  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-10, 10]);
  const opacity = useTransform(x, [-200, -100, 0, 100, 200], [0, 1, 1, 1, 0]);
  const bg = useTransform(
    x,
    [-100, 0, 100],
    ["rgba(254,226,226,1)", "rgba(255,255,255,1)", "rgba(220,252,231,1)"]
  );

  const handleDragEnd = (_e: any, info: any) => {
    if (info.offset.x > 100) {
      onSwipe("right");
    } else if (info.offset.x < -100) {
      onSwipe("left");
    }
  };

  const themeConfig = colorMap[card.theme as ColorTheme];

  return (
    <motion.div
      style={{ x, rotate, backgroundColor: bg, opacity }}
      drag={isTop ? "x" : false}
      dragConstraints={{ left: 0, right: 0 }}
      onDragEnd={handleDragEnd}
      animate={{
        scale: isTop ? 1 : 0.95,
        y: isTop ? 0 : 20,
        zIndex: isTop ? 10 : 0,
        x: direction === "right" && isTop ? 400 : direction === "left" && isTop ? -400 : 0,
      }}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
      className={cn(
        "absolute w-full max-w-[320px] aspect-[3/4] rounded-[40px] shadow-2xl border-2 flex flex-col p-8 cursor-grab active:cursor-grabbing",
        isTop ? themeConfig.border : "border-stone-100"
      )}
    >
      <div className={cn("w-fit px-4 py-2 rounded-full text-xs font-black uppercase tracking-wider mb-6", themeConfig.text)} style={{ backgroundColor: themeConfig.bgLight }}>
        {card.category}
      </div>
      
      <div className="flex-1 flex flex-col justify-center">
        <h3 className="text-3xl font-black text-stone-900 leading-tight mb-4">
          {card.title}
        </h3>
        <p className="text-stone-500 text-sm font-medium leading-relaxed">
          今日、この目標に向かって実際に行動しましたか？
        </p>
      </div>
      
      <div className="flex justify-between items-center text-xs font-bold text-stone-300 px-2 mt-auto opacity-60">
        <div className="flex items-center gap-1"><X className="w-4 h-4" /> NO</div>
        <div className="flex items-center gap-1">YES <Check className="w-4 h-4" /></div>
      </div>
    </motion.div>
  );
}
