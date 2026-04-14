import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { ArrowLeft, Edit3, CheckCircle2, Sparkles, AlertCircle, Plus, Trash2 } from "lucide-react";
import { useNavigate } from "react-router";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Mock goals for review
const initialGoals = [
  { id: 1, category: "技術力", title: "1日1時間のコーディング", progress: 80, resonance: 95, status: "active" },
  { id: 2, category: "技術力", title: "OSSにPRを出す", progress: 10, resonance: 20, status: "needs_review" },
  { id: 3, category: "発信力", title: "週1回ブログ更新", progress: 60, resonance: 50, status: "active" },
  { id: 4, category: "健康", title: "毎朝ランニング", progress: 100, resonance: 100, status: "completed" },
  { id: 5, category: "マインド", title: "完璧主義を捨てる", progress: 40, resonance: 60, status: "active" },
];

export function GoalReview() {
  const navigate = useNavigate();
  const [goals, setGoals] = useState(initialGoals);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [editTitle, setEditTitle] = useState("");

  const handleEdit = (goal: any) => {
    setEditingId(goal.id);
    setEditTitle(goal.title);
  };

  const handleSave = (id: number) => {
    setGoals((prev) => prev.map((g) => (g.id === id ? { ...g, title: editTitle, status: "active" } : g)));
    setEditingId(null);
  };

  const handleDelete = (id: number) => {
    setGoals((prev) => prev.filter((g) => g.id !== id));
  };

  const handleClear = (id: number) => {
    setGoals((prev) => prev.map((g) => (g.id === id ? { ...g, progress: 100, resonance: 100, status: "completed" } : g)));
  };

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-hidden relative font-sans">
      <div className="pt-16 px-6 pb-4 bg-white border-b border-stone-200 z-10 sticky top-0 flex items-center justify-between shadow-sm">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-100 transition-colors">
          <ArrowLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="flex items-center gap-2 font-bold text-stone-800 tracking-tight text-lg">
          <Edit3 className="w-5 h-5 text-indigo-500" />
          目標の見直し
        </div>
        <button onClick={() => navigate(-1)} className="text-sm font-bold text-indigo-600 hover:text-indigo-700">
          完了
        </button>
      </div>

      <div className="flex-1 overflow-y-auto px-6 py-6 pb-32">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-indigo-50 border border-indigo-100 rounded-3xl p-6 mb-8 relative overflow-hidden"
        >
          <div className="absolute -right-4 -top-4 w-24 h-24 bg-indigo-200/50 rounded-full blur-xl pointer-events-none" />
          <h2 className="text-xl font-black text-indigo-900 mb-2">
            現在の目標は<br/>あなたにフィットしていますか？
          </h2>
          <p className="text-sm text-indigo-700/80 leading-relaxed font-medium">
            これまでの「達成率」を参考に、今の自分に合った目標にアップデートしたり、達成済みのものは新しく設定しましょう。
          </p>
        </motion.div>

        <div className="space-y-4">
          <AnimatePresence>
            {goals.map((goal) => (
              <motion.div
                key={goal.id}
                layout
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                className={cn(
                  "bg-white border rounded-[24px] p-5 shadow-sm relative overflow-hidden transition-all",
                  goal.status === "needs_review" ? "border-amber-300 bg-amber-50/30" :
                  goal.status === "completed" ? "border-green-200 bg-green-50/50" : "border-stone-200"
                )}
              >
                {goal.status === "needs_review" && (
                  <div className="absolute top-0 right-0 bg-amber-100 text-amber-700 text-[10px] font-bold px-3 py-1 rounded-bl-xl flex items-center gap-1">
                    <AlertCircle className="w-3 h-3" />
                    見直し推奨
                  </div>
                )}
                {goal.status === "completed" && (
                  <div className="absolute inset-0 bg-green-50/10 pointer-events-none" />
                )}

                <div className="flex justify-between items-start mb-3">
                  <span className="text-[10px] font-bold uppercase tracking-wider text-stone-400 bg-stone-100 px-2 py-1 rounded-full">
                    {goal.category}
                  </span>
                  
                  {goal.status === "completed" && (
                    <span className="text-green-600 text-xs font-bold flex items-center gap-1">
                      <Sparkles className="w-4 h-4" /> クリア済
                    </span>
                  )}
                </div>

                {editingId === goal.id ? (
                  <div className="flex gap-2 mb-4">
                    <input
                      value={editTitle}
                      onChange={(e) => setEditTitle(e.target.value)}
                      className="flex-1 bg-stone-100 border-none rounded-xl px-4 py-2 font-bold text-stone-800 focus:ring-2 focus:ring-indigo-500 outline-none"
                      autoFocus
                    />
                    <button
                      onClick={() => handleSave(goal.id)}
                      className="bg-indigo-600 text-white px-4 py-2 rounded-xl font-bold text-sm"
                    >
                      保存
                    </button>
                  </div>
                ) : (
                  <h3 className={cn(
                    "text-lg font-black text-stone-800 mb-4",
                    goal.status === "completed" && "text-stone-400 line-through"
                  )}>
                    {goal.title}
                  </h3>
                )}

                {!editingId && goal.status !== "completed" && (
                  <>
                    <div className="mb-4">
                      <div className="flex justify-between text-xs font-bold text-stone-500 mb-1">
                        <span>アクション実行度</span>
                        <span className={cn(
                          goal.resonance < 40 ? "text-amber-600" : "text-indigo-600"
                        )}>{goal.resonance}%</span>
                      </div>
                      <div className="w-full h-1.5 bg-stone-100 rounded-full overflow-hidden">
                        <div 
                          className={cn("h-full", goal.resonance < 40 ? "bg-amber-400" : "bg-indigo-500")}
                          style={{ width: `${goal.resonance}%` }}
                        />
                      </div>
                    </div>

                    <div className="flex gap-2 border-t border-stone-100 pt-4 mt-2">
                      <button
                        onClick={() => handleEdit(goal)}
                        className="flex-1 py-2 bg-stone-50 text-stone-600 rounded-xl font-bold text-sm hover:bg-stone-100 transition-colors flex items-center justify-center gap-2"
                      >
                        <Edit3 className="w-4 h-4" /> 修正
                      </button>
                      <button
                        onClick={() => handleClear(goal.id)}
                        className="flex-1 py-2 bg-green-50 text-green-600 rounded-xl font-bold text-sm hover:bg-green-100 transition-colors flex items-center justify-center gap-2"
                      >
                        <CheckCircle2 className="w-4 h-4" /> 達成
                      </button>
                      <button
                        onClick={() => handleDelete(goal.id)}
                        className="w-10 flex items-center justify-center bg-red-50 text-red-500 rounded-xl hover:bg-red-100 transition-colors"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </>
                )}

                {goal.status === "completed" && (
                  <div className="border-t border-green-100 pt-4 mt-2">
                    <button className="w-full py-2.5 bg-white border border-green-200 text-green-700 rounded-xl font-bold text-sm hover:bg-green-50 transition-colors flex items-center justify-center gap-2 shadow-sm">
                      <Plus className="w-4 h-4" /> この枠に新しい目標を追加
                    </button>
                  </div>
                )}
              </motion.div>
            ))}
          </AnimatePresence>

          <button className="w-full py-4 border-2 border-dashed border-stone-300 text-stone-500 rounded-[24px] font-bold hover:bg-stone-50 hover:border-stone-400 transition-all flex items-center justify-center gap-2">
            <Plus className="w-5 h-5" /> まだ空いている枠に目標を追加
          </button>
        </div>
      </div>
    </div>
  );
}