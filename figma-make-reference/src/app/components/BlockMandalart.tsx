import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { ArrowLeft, Sparkles, CheckCircle2, Layers, Grid2X2, Calendar } from "lucide-react";
import { useNavigate } from "react-router";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const colorMap = {
  blue: { base: "bg-blue-500", dark: "bg-blue-700", text: "text-blue-400", border: "border-blue-400" },
  orange: { base: "bg-orange-500", dark: "bg-orange-700", text: "text-orange-400", border: "border-orange-400" },
  green: { base: "bg-green-500", dark: "bg-green-700", text: "text-green-400", border: "border-green-400" },
  purple: { base: "bg-purple-500", dark: "bg-purple-700", text: "text-purple-400", border: "border-purple-400" },
  yellow: { base: "bg-yellow-400", dark: "bg-yellow-600", text: "text-yellow-400", border: "border-yellow-300" }
};

type ColorTheme = "blue" | "orange" | "green" | "purple";

// Mock data based on MandalartView
const initialCategories = [
  {
    id: 1,
    title: "圧倒的な技術力",
    color: "blue" as ColorTheme,
    blocks: [
      { id: 101, title: "1日1時���のコーディング", progress: 80, resonance: 90, cleared: false },
      { id: 102, title: "新しい言語を触る", progress: 40, resonance: 60, cleared: false },
      { id: 103, title: "OSSにPRを出す", progress: 10, resonance: 30, cleared: false },
      { id: 104, title: "技術書を月1冊読む", progress: 100, resonance: 95, cleared: true },
      { id: 105, title: "アルゴリズムを解く", progress: 20, resonance: 40, cleared: false },
      { id: 106, title: "アーキテクチャを学ぶ", progress: 60, resonance: 70, cleared: false },
      { id: 107, title: "パフォーマンスチューニング", progress: 5, resonance: 20, cleared: false },
      { id: 108, title: "コードレビュー依頼", progress: 50, resonance: 80, cleared: false },
    ],
  },
  {
    id: 2,
    title: "継続的な発信力",
    color: "orange" as ColorTheme,
    blocks: [
      { id: 201, title: "週1回ブログ更新", progress: 70, resonance: 85, cleared: false },
      { id: 202, title: "Twitterで毎日発信", progress: 90, resonance: 90, cleared: false },
      { id: 203, title: "LT会に月1回登壇", progress: 30, resonance: 50, cleared: false },
      { id: 204, title: "Qiitaで記事作成", progress: 50, resonance: 70, cleared: false },
      { id: 205, title: "勉強会を主催する", progress: 0, resonance: 10, cleared: false },
      { id: 206, title: "Podcastを始める", progress: 10, resonance: 40, cleared: false },
      { id: 207, title: "ポートフォリオ更新", progress: 100, resonance: 100, cleared: true },
      { id: 208, title: "YouTubeで解説動画", progress: 0, resonance: 20, cleared: false },
    ],
  },
  {
    id: 3,
    title: "強靭な肉体と健康",
    color: "green" as ColorTheme,
    blocks: [
      { id: 301, title: "週3回の筋トレ", progress: 60, resonance: 80, cleared: false },
      { id: 302, title: "毎朝ランニング", progress: 40, resonance: 50, cleared: false },
      { id: 303, title: "7時間以上の睡眠", progress: 90, resonance: 95, cleared: false },
      { id: 304, title: "ジャンクフード禁止", progress: 20, resonance: 30, cleared: false },
      { id: 305, title: "プロテイン摂取", progress: 80, resonance: 80, cleared: false },
      { id: 306, title: "瞑想10分", progress: 50, resonance: 60, cleared: false },
      { id: 307, title: "姿勢改善ストレッチ", progress: 70, resonance: 75, cleared: false },
      { id: 308, title: "水分2リットル", progress: 100, resonance: 90, cleared: true },
    ],
  },
  {
    id: 4,
    title: "マインドセット",
    color: "purple" as ColorTheme,
    blocks: [
      { id: 401, title: "自己否定をしない", progress: 50, resonance: 70, cleared: false },
      { id: 402, title: "他者と比較しない", progress: 60, resonance: 80, cleared: false },
      { id: 403, title: "毎日3つの感謝", progress: 80, resonance: 90, cleared: false },
      { id: 404, title: "失敗を恐れない", progress: 40, resonance: 50, cleared: false },
      { id: 405, title: "完璧主義を捨てる", progress: 70, resonance: 85, cleared: false },
      { id: 406, title: "とりあえず始める", progress: 90, resonance: 95, cleared: false },
      { id: 407, title: "フィードバック歓迎", progress: 100, resonance: 100, cleared: true },
      { id: 408, title: "常に好奇心を持つ", progress: 80, resonance: 80, cleared: false },
    ],
  },
];

export function BlockMandalart() {
  const navigate = useNavigate();
  const [categories, setCategories] = useState(initialCategories);
  const [selectedBlock, setSelectedBlock] = useState<any | null>(null);

  const handleClear = (categoryId: number, blockId: number) => {
    setCategories((prev) =>
      prev.map((c) => {
        if (c.id === categoryId) {
          return {
            ...c,
            blocks: c.blocks.map((b) => (b.id === blockId ? { ...b, cleared: true, progress: 100 } : b)),
          };
        }
        return c;
      })
    );
    setSelectedBlock(null);
  };

  return (
    <div className="flex flex-col h-full w-full bg-zinc-950 overflow-hidden relative font-sans text-white">
      {/* Header */}
      <div className="pt-16 px-6 pb-4 flex items-center justify-between z-10 sticky top-0 bg-zinc-950/90 backdrop-blur-md border-b border-zinc-900 shadow-sm">
        <div className="text-xl font-black text-white flex items-center gap-2 tracking-tight">
          <Layers className="w-5 h-5 text-indigo-400" />
          現在の目標
        </div>
        <div className="flex bg-zinc-900 p-1 rounded-2xl gap-1 whitespace-nowrap">
          <button className="bg-zinc-800 text-white px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 shadow-sm cursor-default whitespace-nowrap">
            <Layers className="w-3.5 h-3.5" /> ブロック
          </button>
          <button 
            onClick={() => navigate('/app/mandalart')}
            className="text-zinc-500 px-3 py-1.5 rounded-xl text-xs font-bold flex items-center gap-1.5 hover:text-white transition-colors whitespace-nowrap"
          >
            <Grid2X2 className="w-3.5 h-3.5" /> リスト
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-4 pb-32">
        <div className="text-center my-6">
          <p className="text-sm text-zinc-400 mb-2 font-bold tracking-widest">積み重ねた努力の結晶</p>
          <p className="text-xs text-zinc-500 mb-6">目標の達成度に応じてブロックが高く積み上がります</p>
          <div className="flex items-center justify-center gap-4 text-xs font-medium text-zinc-400">
            <span className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 bg-zinc-800 rounded-sm" />未着手</span>
            <span className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 bg-white rounded-sm" />継続中</span>
            <span className="flex items-center gap-1.5"><div className="w-2.5 h-2.5 bg-yellow-400 shadow-[0_0_8px_rgba(250,204,21,0.8)] rounded-sm" />クリア済</span>
          </div>
        </div>

        <div className="flex flex-col gap-10 pb-8">
          {categories.map((category) => (
            <CategoryGrid key={category.id} category={category} onClickBlock={(b) => setSelectedBlock({...b, categoryId: category.id, color: category.color})} />
          ))}
        </div>
      </div>

      {/* Block Detail Modal */}
      <AnimatePresence>
        {selectedBlock && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 z-50 flex items-center justify-center p-6 bg-black/60 backdrop-blur-sm"
            onClick={() => setSelectedBlock(null)}
          >
            <motion.div
              layoutId={`block-${selectedBlock.id}`}
              onClick={(e) => e.stopPropagation()}
              className="w-full max-w-sm bg-zinc-900 border border-zinc-800 rounded-[32px] p-6 shadow-2xl relative overflow-hidden"
            >
              {selectedBlock.cleared && (
                <div className="absolute top-0 left-0 right-0 h-2 bg-yellow-400 shadow-[0_0_20px_rgba(250,204,21,1)]" />
              )}
              {!selectedBlock.cleared && (
                <div className={cn("absolute top-0 left-0 right-0 h-2", colorMap[selectedBlock.color as ColorTheme].base)} />
              )}

              <div className="flex justify-between items-start mb-6 mt-2">
                <div>
                  <p className="text-xs text-zinc-500 font-bold mb-1 uppercase tracking-wider">Target Goal</p>
                  <h3 className="text-xl font-black text-white leading-tight">{selectedBlock.title}</h3>
                </div>
                {selectedBlock.cleared && (
                  <div className="bg-yellow-400/20 text-yellow-400 p-2 rounded-full">
                    <Sparkles className="w-5 h-5" />
                  </div>
                )}
              </div>

              <div className="space-y-5 mb-8">
                <div>
                  <div className="flex justify-between text-sm mb-2">
                    <span className="text-zinc-400 font-bold">進捗度 (Progress)</span>
                    <span className="font-bold text-white">{selectedBlock.progress}%</span>
                  </div>
                  <div className="w-full h-2.5 bg-zinc-800 rounded-full overflow-hidden">
                    <div 
                      className={cn("h-full transition-all duration-1000", selectedBlock.cleared ? "bg-yellow-400" : colorMap[selectedBlock.color as ColorTheme].base)} 
                      style={{ width: `${selectedBlock.progress}%` }}
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-zinc-400 font-bold">達成率 (Achievement)</span>
                    <span className="font-bold text-white">{selectedBlock.resonance} / 100</span>
                  </div>
                  <p className="text-[10px] text-zinc-500 mb-2">目標に向けた行動の積み重ねを示します</p>
                  <div className="flex gap-1">
                    {Array.from({ length: 10 }).map((_, i) => (
                      <div 
                        key={i} 
                        className={cn(
                          "h-2.5 flex-1 rounded-sm",
                          i < Math.ceil(selectedBlock.resonance / 10) 
                            ? selectedBlock.cleared ? "bg-yellow-400" : colorMap[selectedBlock.color as ColorTheme].base 
                            : "bg-zinc-800"
                        )} 
                      />
                    ))}
                  </div>
                </div>
              </div>

              {!selectedBlock.cleared ? (
                <div className="space-y-3">
                  <button
                    onClick={() => navigate('/time-allocation', { state: { selectedCategory: categories.find(c => c.id === selectedBlock.categoryId), selectedBlock } })}
                    className="w-full py-3.5 bg-indigo-600 hover:bg-indigo-500 text-white font-bold rounded-xl flex items-center justify-center gap-2 transition-colors shadow-sm"
                  >
                    <Calendar className="w-5 h-5" /> カレンダーに時間を確保する
                  </button>
                  <button
                    onClick={() => handleClear(selectedBlock.categoryId, selectedBlock.id)}
                    className="w-full py-3.5 bg-zinc-800 hover:bg-zinc-700 text-white font-bold rounded-xl flex items-center justify-center gap-2 transition-colors border border-zinc-700"
                  >
                    <CheckCircle2 className="w-5 h-5" /> 目標をクリアする
                  </button>
                  <button
                    onClick={() => setSelectedBlock(null)}
                    className="w-full py-3 bg-transparent text-zinc-400 font-bold rounded-xl hover:text-white transition-colors"
                  >
                    閉じる
                  </button>
                </div>
              ) : (
                <div className="space-y-3">
                  <button
                    className="w-full py-3.5 bg-yellow-500 hover:bg-yellow-400 text-black font-black rounded-xl flex items-center justify-center gap-2 transition-colors shadow-[0_0_15px_rgba(250,204,21,0.3)]"
                  >
                    <Layers className="w-5 h-5" /> 新しい目標を積み上げる
                  </button>
                  <button
                    onClick={() => setSelectedBlock(null)}
                    className="w-full py-3 bg-transparent text-zinc-400 font-bold rounded-xl hover:text-white transition-colors"
                  >
                    閉じる
                  </button>
                </div>
              )}
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

function CategoryGrid({ category, onClickBlock }: { category: any, onClickBlock: (block: any) => void }) {
  const theme = colorMap[category.color as ColorTheme];

  // Map 8 items to a 3x3 grid around a center cell
  const gridOrder = [
    category.blocks[0], category.blocks[1], category.blocks[2],
    category.blocks[3], null,               category.blocks[4],
    category.blocks[5], category.blocks[6], category.blocks[7],
  ];

  return (
    <div className="w-full max-w-md mx-auto">
      <h3 className={cn("text-lg font-black mb-4 text-center tracking-tight", theme.text)}>
        {category.title}
      </h3>
      
      <div className="grid grid-cols-3 gap-2 px-2">
        {gridOrder.map((block, i) => {
          if (block === null) {
            // Center cell represents the Category itself
            return (
              <div key="center" className="relative aspect-square">
                <div className={cn("absolute inset-0 bg-zinc-900 rounded-[14px] flex items-center justify-center p-2 shadow-inner border border-zinc-800/50", theme.text)}>
                  <span className="text-xs font-black text-center leading-tight">
                    {category.title}
                  </span>
                </div>
              </div>
            );
          }

          const isCleared = block.cleared;
          const activeTheme = isCleared ? colorMap.yellow : theme;
          
          // Math for the 3D block extrusion
          const maxExtrusion = 14; // How many pixels the block can pop up
          const extrusion = isCleared ? maxExtrusion : Math.max(2, (block.progress / 100) * maxExtrusion);
          const resonanceLevel = Math.ceil((block.resonance / 100) * 3);

          return (
            <div 
              key={block.id} 
              className="relative aspect-square w-full mt-3 cursor-pointer group" 
              onClick={() => onClickBlock(block)}
            >
              {/* Glow for cleared items */}
              {isCleared && (
                <div className="absolute inset-0 bg-yellow-400/20 blur-xl rounded-full translate-y-2" />
              )}

              {/* 3D Bottom Face (Side wall of the block) */}
              <div
                className={cn("absolute bottom-0 left-0 right-0 rounded-[14px] transition-all duration-500", activeTheme.dark)}
                style={{ height: `calc(100% - ${maxExtrusion}px + ${extrusion}px)` }}
              />

              {/* 3D Top Face (The surface of the block) */}
              <motion.div
                layoutId={`block-${block.id}`}
                initial={false}
                animate={{ y: -extrusion }}
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                className={cn(
                  "absolute bottom-0 left-0 right-0 rounded-[14px] border-t p-2 flex flex-col justify-between shadow-lg transition-colors duration-500",
                  activeTheme.base,
                  activeTheme.border
                )}
                style={{ height: `calc(100% - ${maxExtrusion}px)` }}
              >
                {/* 3D top edge shine */}
                <div className="absolute top-0 left-0 right-0 h-2 bg-white/20 rounded-t-[14px] pointer-events-none" />

                <span className={cn(
                  "text-[10px] sm:text-[11px] font-bold leading-[1.3] z-10 line-clamp-3 overflow-hidden",
                  isCleared ? "text-yellow-950" : "text-white"
                )}>
                  {block.title}
                </span>

                <div className="flex justify-between items-end z-10 pt-1">
                  <div className="flex gap-[3px]">
                    {!isCleared && [...Array(3)].map((_, i) => (
                      <div 
                        key={i} 
                        className={cn(
                          "w-1.5 h-1.5 rounded-full shadow-inner", 
                          i < resonanceLevel ? "bg-white" : "bg-black/20"
                        )} 
                      />
                    ))}
                  </div>
                  {isCleared && <Sparkles className="w-3.5 h-3.5 text-yellow-700" />}
                </div>
              </motion.div>
            </div>
          );
        })}
      </div>
    </div>
  );
}