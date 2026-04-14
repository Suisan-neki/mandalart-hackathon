import { useNavigate } from "react-router";
import { Calendar, Sparkles, LayoutGrid } from "lucide-react";
import { motion } from "motion/react";

export function DemoPortal() {
  const navigate = useNavigate();

  return (
    <div className="min-h-full bg-stone-50 flex flex-col items-center justify-center p-6">
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-sm space-y-6"
      >
        <div className="text-center space-y-2 mb-8">
          <h1 className="text-2xl font-black text-stone-800">機能プレビュー</h1>
          <p className="text-sm text-stone-500 font-medium">
            新しく追加された機能を個別に確認できます
          </p>
        </div>

        <div className="space-y-4">
          <button
            onClick={() => navigate("/time-allocation")}
            className="w-full bg-white p-5 rounded-2xl shadow-sm border border-stone-200 flex items-center gap-4 hover:border-indigo-300 transition-colors text-left"
          >
            <div className="w-12 h-12 rounded-full bg-indigo-50 flex items-center justify-center shrink-0">
              <Calendar className="w-6 h-6 text-indigo-600" />
            </div>
            <div>
              <div className="font-bold text-stone-800">時間資源の配分</div>
              <div className="text-xs text-stone-500 mt-1">Googleカレンダー連携・予定確保UI</div>
            </div>
          </button>

          <button
            onClick={() => navigate("/weekly-report")}
            className="w-full bg-white p-5 rounded-2xl shadow-sm border border-stone-200 flex items-center gap-4 hover:border-indigo-300 transition-colors text-left"
          >
            <div className="w-12 h-12 rounded-full bg-indigo-50 flex items-center justify-center shrink-0">
              <Sparkles className="w-6 h-6 text-indigo-600" />
            </div>
            <div>
              <div className="font-bold text-stone-800">今週の振り返り</div>
              <div className="text-xs text-stone-500 mt-1">温かいテキスト表現による行動分析</div>
            </div>
          </button>
        </div>

        <div className="pt-8 border-t border-stone-200">
          <button
            onClick={() => navigate("/app/block-mandalart")}
            className="w-full py-4 bg-stone-800 text-white font-bold rounded-xl flex items-center justify-center gap-2 hover:bg-stone-700 transition-colors"
          >
            <LayoutGrid className="w-5 h-5" />
            アプリ全体のフローで確認する
          </button>
        </div>
      </motion.div>
    </div>
  );
}
