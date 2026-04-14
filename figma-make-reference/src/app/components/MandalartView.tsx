import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Check, X, Maximize2, Zap, Brain, Flame, Activity, Layers, Grid2X2 } from "lucide-react";
import { useNavigate } from "react-router";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const colorMap = {
  blue: { bg: "bg-blue-500/10", border: "border-blue-500/30", text: "text-blue-500", solid: "bg-blue-600" },
  orange: { bg: "bg-orange-500/10", border: "border-orange-500/30", text: "text-orange-500", solid: "bg-orange-600" },
  green: { bg: "bg-green-500/10", border: "border-green-500/30", text: "text-green-500", solid: "bg-green-600" },
  purple: { bg: "bg-purple-500/10", border: "border-purple-500/30", text: "text-purple-500", solid: "bg-purple-600" },
};

type ColorTheme = keyof typeof colorMap;

const mandalartData = {
  mainGoal: "最強のエンジニアになる",
  subGoals: [
    {
      id: 1,
      title: "圧倒的な技術力",
      color: "blue" as ColorTheme,
      icon: <Brain className="w-5 h-5" />,
      actions: ["1日1時間のコーディング", "新しい言語を触る", "OSSにPRを出す", "技術��を月1冊読む", "アルゴリズムを解く", "アーキテクチャを学ぶ", "パフォーマンスチューニング", "コードレビュー依頼"],
    },
    {
      id: 2,
      title: "継続的な発信力",
      color: "orange" as ColorTheme,
      icon: <Flame className="w-5 h-5" />,
      actions: ["週1回ブログ更新", "Twitterで毎日発信", "LT会に月1回登壇", "Qiitaで記事作成", "勉強会を主催する", "Podcastを始める", "ポートフォリオ更新", "YouTubeで解説動画"],
    },
    {
      id: 3,
      title: "強靭な肉体と健康",
      color: "green" as ColorTheme,
      icon: <Activity className="w-5 h-5" />,
      actions: ["週3回の筋トレ", "毎朝ランニング", "7時間以上の睡眠", "ジャンクフード禁止", "プロテイン摂取", "瞑想10分", "姿勢改善ストレッチ", "水分2リットル"],
    },
    {
      id: 4,
      title: "マインドセット",
      color: "purple" as ColorTheme,
      icon: <Zap className="w-5 h-5" />,
      actions: ["自己否定をしない", "他者と比較しない", "毎日3つの感謝", "失敗を恐れない", "完璧主義を捨てる", "とりあえず始める", "フィードバック歓迎", "常に好奇心を持つ"],
    },
  ],
};

export function MandalartView() {
  const [expandedId, setExpandedId] = useState<number | null>(null);
  const navigate = useNavigate();

  return (
    <div className="flex flex-col h-full w-full bg-zinc-950 text-white font-sans relative overflow-hidden">
      <div className="pt-16 px-6 pb-6 z-10 sticky top-0 bg-zinc-950/80 backdrop-blur-md border-b border-zinc-900">
        <div className="flex justify-between items-center mb-1">
          <p className="text-zinc-500 text-[10px] font-bold tracking-widest uppercase">MAIN GOAL</p>
          <div className="flex bg-zinc-900 p-1 rounded-2xl gap-1 whitespace-nowrap">
            <button 
              onClick={() => navigate('/app/block-mandalart')}
              className="text-zinc-500 px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 hover:text-white transition-colors whitespace-nowrap"
            >
              <Layers className="w-3.5 h-3.5" /> ブロック
            </button>
            <button className="bg-zinc-800 text-white px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 shadow-sm whitespace-nowrap">
              <Grid2X2 className="w-3.5 h-3.5" /> リスト
            </button>
          </div>
        </div>
        <h1 className="text-2xl font-black tracking-tight text-white mt-2">
          {mandalartData.mainGoal}
        </h1>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-32">
        {mandalartData.subGoals.map((sub) => {
          const theme = colorMap[sub.color];
          
          return (
            <motion.div
              key={sub.id}
              layoutId={`card-${sub.id}`}
              onClick={() => setExpandedId(sub.id)}
              className={cn(
                "relative p-6 rounded-[32px] border cursor-pointer overflow-hidden transition-colors shadow-sm",
                theme.bg,
                theme.border
              )}
            >
              <div className={cn("flex items-center gap-3 mb-4", theme.text)}>
                {sub.icon}
                <h3 className="font-bold text-lg tracking-tight text-white">{sub.title}</h3>
              </div>
              
              <div className="flex flex-wrap gap-2">
                {sub.actions.slice(0, 4).map((action, i) => (
                  <span key={i} className="text-xs px-3 py-1.5 bg-zinc-900/50 rounded-full border border-white/5 text-zinc-300">
                    {action}
                  </span>
                ))}
                {sub.actions.length > 4 && (
                  <span className="text-[10px] font-bold px-2 py-1.5 bg-white/5 rounded-full text-zinc-400 flex items-center justify-center">
                    +{sub.actions.length - 4}
                  </span>
                )}
              </div>
              
              <div className="absolute right-0 bottom-0 opacity-10 blur-xl pointer-events-none scale-150">
                {sub.icon}
              </div>
            </motion.div>
          );
        })}
      </div>

      {/* Detail/Edit Modal */}
      <AnimatePresence>
        {expandedId !== null && (
          <ExpandedCard
            subGoal={mandalartData.subGoals.find((s) => s.id === expandedId)!}
            onClose={() => setExpandedId(null)}
          />
        )}
      </AnimatePresence>
    </div>
  );
}

function ExpandedCard({ subGoal, onClose }: { subGoal: any; onClose: () => void }) {
  const theme = colorMap[subGoal.color as ColorTheme];

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="absolute inset-0 z-50 flex flex-col bg-zinc-950 backdrop-blur-xl"
    >
      <motion.div
        layoutId={`card-${subGoal.id}`}
        className={cn(
          "flex flex-col h-full w-full rounded-none overflow-hidden",
          theme.bg
        )}
      >
        <div className="p-6 pt-16 flex justify-between items-center border-b border-white/5">
          <div className={cn("flex items-center gap-3", theme.text)}>
            {subGoal.icon}
            <h2 className="text-xl font-black text-white">{subGoal.title}</h2>
          </div>
          <button
            onClick={onClose}
            className="w-10 h-10 rounded-full bg-white/10 flex items-center justify-center text-white active:scale-95"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto p-6">
          <p className="text-sm text-zinc-400 mb-6 leading-relaxed">
            このサブテーマを構成する8つのアクション要素です。これらを達成することで「{subGoal.title}」が現実のものになります。
          </p>

          <div className="grid grid-cols-1 gap-3">
            {subGoal.actions.map((action: string, i: number) => (
              <div key={i} className="bg-zinc-900 border border-zinc-800 rounded-2xl p-4 flex items-center gap-4">
                <div className={cn("w-8 h-8 rounded-full flex items-center justify-center font-bold text-xs font-mono", theme.solid, "text-white")}>
                  {i + 1}
                </div>
                <input
                  defaultValue={action}
                  className="flex-1 bg-transparent text-white font-medium focus:outline-none"
                />
              </div>
            ))}
          </div>
        </div>

        <div className="p-6 bg-zinc-950 border-t border-zinc-900">
          <button
            onClick={onClose}
            className={cn(
              "w-full py-4 rounded-2xl font-bold flex items-center justify-center gap-2 text-white transition-transform active:scale-95 shadow-lg",
              theme.solid
            )}
          >
            <Check className="w-5 h-5" /> 変更を保存
          </button>
        </div>
      </motion.div>
    </motion.div>
  );
}
