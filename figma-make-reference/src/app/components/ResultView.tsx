import { useState, useEffect } from "react";
import { motion } from "motion/react";
import { ChevronLeft, Target, Activity, Zap, CheckCircle2, ChevronRight, TrendingUp, Calendar, Sparkles } from "lucide-react";
import { useNavigate } from "react-router";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function ResultView() {
  const navigate = useNavigate();
  const [activityRate, setActivityRate] = useState(0);
  
  // Example dummy data
  const targetRate = 45; // Below 50 is low, > 80 is high.

  useEffect(() => {
    // Animate the resonance value up to the target
    const duration = 2000;
    const steps = 60;
    const interval = duration / steps;
    const increment = targetRate / steps;

    let current = 0;
    const timer = setInterval(() => {
      current += increment;
      if (current >= targetRate) {
        setActivityRate(targetRate);
        clearInterval(timer);
      } else {
        setActivityRate(Math.floor(current));
      }
    }, interval);

    return () => clearInterval(timer);
  }, [targetRate]);

  const isHighRate = targetRate >= 80;
  const isMediumRate = targetRate >= 60 && targetRate < 80;

  // Determine theme colors based on resonance level
  const theme = isHighRate 
    ? { 
        bg: "from-amber-50 to-orange-50", 
        ring: "border-amber-400/30", 
        core: "bg-gradient-to-br from-amber-400 to-orange-500",
        text: "text-amber-600",
        glow: "bg-amber-400/20"
      }
    : isMediumRate
    ? {
        bg: "from-blue-50 to-indigo-50",
        ring: "border-blue-400/30",
        core: "bg-gradient-to-br from-blue-400 to-indigo-500",
        text: "text-blue-600",
        glow: "bg-blue-400/20"
      }
    : {
        bg: "from-purple-50 to-pink-50",
        ring: "border-purple-400/30",
        core: "bg-gradient-to-br from-purple-400 to-pink-500",
        text: "text-purple-600",
        glow: "bg-purple-400/20"
      };

  return (
    <div className={cn("flex flex-col h-full w-full font-sans overflow-y-auto pb-24 bg-gradient-to-b", theme.bg)}>
      <div className="flex items-center justify-between p-6 pt-16 relative z-10">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-black/5 transition-colors">
          <ChevronLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="font-bold text-stone-800 tracking-tight text-sm uppercase">
          Review Report
        </div>
        <div className="w-10"></div>
      </div>

      <div className="flex flex-col items-center justify-center pt-8 pb-12 relative px-6">
        {/* Resonance Ring Animation */}
        <div className="relative w-64 h-64 flex items-center justify-center">
          <motion.div
            animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
            transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
            className={cn("absolute inset-0 rounded-full blur-[60px]", theme.glow)}
          />
          <motion.div
            animate={{ scale: [1, 1.1, 1], opacity: [0.5, 0.8, 0.5] }}
            transition={{ duration: 3, repeat: Infinity, ease: "easeInOut", delay: 0.5 }}
            className={cn("absolute -inset-8 border rounded-full", theme.ring)}
          />
          <motion.div
            animate={{ scale: [1, 1.05, 1], opacity: [0.7, 1, 0.7] }}
            transition={{ duration: 3, repeat: Infinity, ease: "easeInOut", delay: 1 }}
            className={cn("absolute -inset-4 border rounded-full", theme.ring)}
          />
          
          <div className="relative z-10 bg-white/80 backdrop-blur-md w-full h-full rounded-full shadow-[0_20px_40px_-15px_rgba(0,0,0,0.1)] flex flex-col items-center justify-center border border-white/50">
            <span className="text-stone-400 font-bold tracking-widest uppercase text-xs mb-1">達成率</span>
            <div className="flex items-baseline gap-1">
              <span className={cn("text-6xl font-black tracking-tighter", theme.text)}>
                {activityRate}
              </span>
              <span className="text-2xl font-bold text-stone-300">%</span>
            </div>
            
            <div className="mt-4 flex gap-4 px-6 text-center whitespace-nowrap">
              <div>
                <div className="text-[10px] text-stone-400 font-bold mb-1">現在地</div>
                <div className="text-sm font-black text-stone-700">35<span className="text-[10px] font-medium text-stone-400 ml-0.5">項目</span></div>
              </div>
              <div className="w-px h-8 bg-stone-200"></div>
              <div>
                <div className="text-[10px] text-stone-400 font-bold mb-1">目標</div>
                <div className="text-sm font-black text-stone-700">80<span className="text-[10px] font-medium text-stone-400 ml-0.5">項目</span></div>
              </div>
            </div>
          </div>
        </div>

        {/* Empathetic Feedback Message */}
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="mt-12 text-center max-w-sm"
        >
          {isHighRate ? (
             <>
               <h2 className="text-2xl font-black text-stone-800 mb-3 break-keep">素晴らしい達成率です</h2>
               <p className="text-stone-500 text-sm leading-relaxed break-keep">
                 あなたが掲げた目標と、実際の行動がしっかりと結びついています。この調子で、自分を信じて進んでいきましょう。
               </p>
             </>
          ) : isMediumRate ? (
             <>
               <h2 className="text-2xl font-black text-stone-800 mb-3 break-keep">着実に歩んでいます</h2>
               <p className="text-stone-500 text-sm leading-relaxed break-keep">
                 目標に向かって少しずつ着実に進んでいます。焦る必要はありません。まずは今できている自分を褒めてあげてください。
               </p>
             </>
          ) : (
             <>
               <h2 className="text-2xl font-black text-stone-800 mb-3 break-keep">目標の高さは、あなたの才能</h2>
               <p className="text-stone-500 text-sm leading-relaxed mb-6 break-keep">
                 記録を見ると、少し目標が先行しているようです。でも大丈夫です。それはあなたが誰よりも高く飛びたいと願っている証拠だから。
               </p>
               <div className="bg-white/60 backdrop-blur-md rounded-2xl p-5 border border-white shadow-sm text-left">
                 <div className="flex items-center gap-2 mb-2">
                   <Target className={cn("w-5 h-5", theme.text)} />
                   <span className="font-bold text-stone-800 text-sm">明日のための小さな一歩</span>
                 </div>
                 <p className="text-stone-600 text-xs leading-relaxed">
                   自分を責める必要はありません。明日は、32個の目標の中から「これだけは絶対にやる1つ」を選んで、ハードルを極端に下げてみませんか？
                 </p>
               </div>
             </>
          )}
        </motion.div>
      </div>
      
      {/* Action Breakdown */}
      <div className="px-6 space-y-4 cursor-pointer" onClick={() => navigate("/app/sync-journal")}>
        <div className="flex items-center justify-between mb-2">
          <h3 className="font-bold text-stone-800 text-sm flex items-center gap-2">
            <Activity className="w-4 h-4 text-stone-400" />
            直近の行動ログ
          </h3>
          <ChevronRight className="w-4 h-4 text-stone-400" />
        </div>
        
        <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-100 flex items-center justify-between hover:bg-stone-50 transition-colors">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-green-100 text-green-600 flex items-center justify-center">
              <CheckCircle2 className="w-5 h-5" />
            </div>
            <div>
              <div className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-1">Action</div>
              <div className="font-bold text-stone-800 text-sm">実行できたアクション</div>
            </div>
          </div>
          <div className="text-2xl font-black text-stone-800">4<span className="text-xs text-stone-400 font-medium ml-1">項目</span></div>
        </div>

        <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-100 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="w-10 h-10 rounded-full bg-purple-100 text-purple-600 flex items-center justify-center">
              <TrendingUp className="w-5 h-5" />
            </div>
            <div>
              <div className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-1">To Do</div>
              <div className="font-bold text-stone-800 text-sm">これからのアクション</div>
            </div>
          </div>
          <div className="text-2xl font-black text-stone-800">28<span className="text-xs text-stone-400 font-medium ml-1">項目</span></div>
        </div>
      </div>

      {/* Calendar Insights */}
      <div className="px-6 space-y-3 mt-8">
        <h3 className="font-bold text-stone-800 text-sm flex items-center gap-2 mb-3">
          <Calendar className="w-4 h-4 text-indigo-400" />
          カレンダーインサイト
        </h3>
        
        <button 
          onClick={() => navigate("/time-allocation")}
          className="w-full bg-white rounded-[24px] p-5 shadow-sm border border-stone-100 flex items-center justify-between hover:bg-stone-50 transition-colors"
        >
          <div className="flex items-center gap-4 text-left">
            <div className="w-10 h-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0">
              <Calendar className="w-5 h-5" />
            </div>
            <div>
              <div className="font-bold text-stone-800 text-sm mb-0.5">時間資源の配分</div>
              <div className="text-xs text-stone-500 font-medium break-keep">予定と目標を紐付けて未来をデザインする</div>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-stone-400 shrink-0" />
        </button>

        <button 
          onClick={() => navigate("/weekly-report")}
          className="w-full bg-white rounded-[24px] p-5 shadow-sm border border-stone-100 flex items-center justify-between hover:bg-stone-50 transition-colors"
        >
          <div className="flex items-center gap-4 text-left">
            <div className="w-10 h-10 rounded-full bg-indigo-100 text-indigo-600 flex items-center justify-center shrink-0">
              <Sparkles className="w-5 h-5" />
            </div>
            <div>
              <div className="font-bold text-stone-800 text-sm mb-0.5">今週の振り返り</div>
              <div className="text-xs text-stone-500 font-medium break-keep">カレンダーのデータから次へのヒントを見つける</div>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-stone-400 shrink-0" />
        </button>
      </div>
    </div>
  );
}