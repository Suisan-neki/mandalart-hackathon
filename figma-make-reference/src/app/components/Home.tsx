import { useNavigate, useOutletContext } from "react-router";
import { motion } from "motion/react";
import { Zap, Target, Activity, Flame, ChevronRight, RefreshCw, AlertCircle, BellRing, Sparkles, Plus, ListTodo, Grid3X3, CheckCircle2 } from "lucide-react";

export function Home() {
  const navigate = useNavigate();
  const { setIsSyncing } = useOutletContext<{ setIsSyncing: (val: boolean) => void }>();

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-y-auto pb-6 relative font-sans">
      {/* Header section - 「今日のアクション」タブのヘッダー */}
      <div className="bg-zinc-950 text-white pt-16 pb-10 px-6 rounded-b-[40px] shadow-lg relative z-10">
        <div className="mb-6 flex justify-between items-start gap-4 pr-1">
          <div className="flex-1">
            <p className="text-zinc-400 text-xs font-bold tracking-widest uppercase mb-2">あなたの目標</p>
            <h1 className="text-2xl font-black tracking-tight leading-tight">最強のエンジニアになる</h1>
          </div>
          <div className="flex gap-2 shrink-0 bg-zinc-900/80 p-1.5 rounded-full border border-zinc-800 backdrop-blur-md">
             <button onClick={() => {
               setIsSyncing(true);
               setTimeout(() => setIsSyncing(false), 3000);
             }} className="p-2 bg-zinc-800 rounded-full text-zinc-400 hover:text-white hover:bg-zinc-700 transition-colors" title="同期中アニメーションの表示">
               <RefreshCw className="w-4 h-4" />
             </button>
             <button onClick={() => navigate("/app/error-demo")} className="p-2 bg-zinc-800 rounded-full text-zinc-400 hover:text-white hover:bg-zinc-700 transition-colors" title="エラーUIデモの表示">
               <AlertCircle className="w-4 h-4" />
             </button>
          </div>
        </div>

        {/* 進捗の表示（少しコンパクトに） */}
        <div className="w-full bg-zinc-900 border border-zinc-800 rounded-3xl p-5 mb-2 relative overflow-hidden">
          <div className="absolute right-0 top-0 w-32 h-32 bg-indigo-500/10 rounded-full -mr-16 -mt-16 blur-2xl" />
          
          <div className="relative z-10 flex-1">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Activity className="w-5 h-5 text-indigo-400" />
                <span className="text-sm font-bold text-zinc-300">今週の実行率</span>
              </div>
              <div className="flex items-end gap-1">
                <span className="text-2xl font-black font-mono text-white leading-none tracking-tighter">42</span>
                <span className="text-sm text-zinc-500 font-bold leading-none mb-0.5">%</span>
              </div>
            </div>
            
            <div className="w-full h-2 bg-zinc-800 rounded-full overflow-hidden">
              <motion.div 
                initial={{ width: 0 }}
                animate={{ width: "42%" }}
                transition={{ duration: 1, ease: "easeOut" }}
                className="h-full bg-gradient-to-r from-indigo-600 to-indigo-400 rounded-full"
              />
            </div>
          </div>
        </div>
      </div>

      <div className="px-6 py-8 space-y-6 relative z-0">
        
        {/* 一番やってほしいアクション（今日の実績記録） */}
        <div>
          <h2 className="text-lg font-black text-zinc-800 tracking-tight flex items-center gap-2 mb-4">
            <CheckCircle2 className="w-5 h-5 text-indigo-600" />
            今日やるべきこと
          </h2>

          <motion.button
            whileHover={{ scale: 0.98 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => navigate("/checkin")}
            className="w-full bg-white border border-stone-200 rounded-[32px] p-6 shadow-sm hover:shadow-md transition-all text-left group relative overflow-hidden"
          >
            <div className="absolute right-0 top-0 w-32 h-32 bg-indigo-50 rounded-full -mr-10 -mt-10 blur-2xl opacity-50 transition-opacity group-hover:opacity-100" />
            
            <div className="flex justify-between items-start mb-4 relative z-10">
              <div className="bg-indigo-100 p-3 rounded-2xl text-indigo-600 shadow-inner">
                <Target className="w-6 h-6" />
              </div>
              <span className="bg-indigo-600 text-white text-[10px] font-bold px-3 py-1 rounded-full tracking-widest uppercase">
                未完了（約2分）
              </span>
            </div>
            
            <h3 className="text-xl font-black text-zinc-900 mb-2 relative z-10 tracking-tight">今日できたことを記録する</h3>
            <p className="text-sm text-zinc-500 mb-6 relative z-10 leading-relaxed font-medium">
              今日の行動を振り返り、目標に向けて前進しましょう。小さな一歩も大切な記録です。
            </p>
            
            <div className="flex items-center justify-between bg-stone-50 rounded-xl p-3 relative z-10 border border-stone-100 group-hover:bg-indigo-50 group-hover:border-indigo-100 transition-colors">
              <span className="text-indigo-600 font-bold text-sm ml-2">振り返りをスタート</span>
              <div className="bg-white p-1.5 rounded-lg shadow-sm">
                <ChevronRight className="w-4 h-4 text-indigo-600" />
              </div>
            </div>
          </motion.button>
        </div>

        {/* その他のアクションへの導線（少しトーンを落として整理） */}
        <div>
          <h2 className="text-sm font-bold text-zinc-400 tracking-tight mb-3 px-1 uppercase">
            便利な機能
          </h2>
          <div className="grid grid-cols-2 gap-4">
            {/* タイムライン（できたことログ） */}
            <button 
              onClick={() => navigate("/app/sync-journal")}
              className="bg-white border border-stone-200 rounded-[28px] p-5 shadow-sm hover:shadow-md transition-all text-left flex flex-col justify-between aspect-square group"
            >
              <div className="bg-stone-100 p-3 rounded-2xl w-fit text-stone-600 mb-4 group-hover:bg-stone-200 transition-colors">
                <ListTodo className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-stone-800 text-sm mb-1">できたことの記録</h3>
                <p className="text-[10px] text-stone-500 leading-relaxed font-medium">
                  過去の行動ログ（タイムライン）を見る
                </p>
              </div>
            </button>

            {/* 新しい目標・アクションの追加 */}
            <button 
              onClick={() => navigate("/app/action-edit")}
              className="bg-white border border-stone-200 rounded-[28px] p-5 shadow-sm hover:shadow-md transition-all text-left flex flex-col justify-between aspect-square group"
            >
              <div className="bg-stone-100 p-3 rounded-2xl w-fit text-stone-600 mb-4 group-hover:bg-stone-200 transition-colors">
                <Plus className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-stone-800 text-sm mb-1">アクション追加</h3>
                <p className="text-[10px] text-stone-500 leading-relaxed font-medium">
                  マンダラートに新しい目標を追加する
                </p>
              </div>
            </button>
          </div>
        </div>

        {/* 通知プロンプトは一番下に移動（優先度を下げる） */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="bg-indigo-50 border border-indigo-100 rounded-[28px] p-5 shadow-sm cursor-pointer hover:bg-indigo-100 transition-colors"
          onClick={() => navigate("/app/goal-review")}
        >
          <div className="flex gap-4 items-start">
            <div className="bg-indigo-200/50 p-2.5 rounded-full text-indigo-600">
              <BellRing className="w-5 h-5" />
            </div>
            <div className="flex-1">
              <h3 className="text-indigo-900 font-bold text-sm mb-1 flex items-center gap-1.5">
                目標を見直す時期かも？ <Sparkles className="w-3.5 h-3.5 text-indigo-500" />
              </h3>
              <p className="text-indigo-700/80 text-xs leading-relaxed font-medium">
                1ヶ月が経過しました。現在の目標は今のあなたにフィットしていますか？
              </p>
            </div>
          </div>
        </motion.div>

      </div>
    </div>
  );
}