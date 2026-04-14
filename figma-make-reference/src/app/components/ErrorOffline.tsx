import { useNavigate } from "react-router";
import { ChevronLeft, WifiOff, Globe2, Activity } from "lucide-react";
import { motion } from "motion/react";

export function ErrorOffline() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-y-auto font-sans pb-24">
      {/* Header */}
      <div className="flex items-center justify-between p-6 pt-16 relative z-10">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-200 transition-colors">
          <ChevronLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="w-10"></div>
      </div>

      <div className="flex-1 flex flex-col items-center justify-center p-6 text-center">
        <motion.div 
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5, ease: "easeOut" }}
          className="relative mb-8"
        >
          <div className="absolute inset-0 bg-blue-400/20 blur-3xl rounded-full" />
          <div className="w-24 h-24 bg-gradient-to-br from-blue-100 to-indigo-50 rounded-full border-4 border-white shadow-xl flex items-center justify-center relative z-10 mx-auto">
            <WifiOff className="w-10 h-10 text-blue-500" />
          </div>
        </motion.div>

        <motion.h1 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.1, ease: "easeOut" }}
          className="text-2xl font-black text-stone-900 mb-3 tracking-tight"
        >
          オフラインです
        </motion.h1>
        
        <motion.p 
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.2, ease: "easeOut" }}
          className="text-stone-500 text-sm leading-relaxed max-w-xs mx-auto mb-8"
        >
          現在、ネットワークに接続されていません。<br />
          インターネットに復帰すると、自動的に最新の行動ログが同期されます。
        </motion.p>

        <motion.div
          initial={{ y: 20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.3, ease: "easeOut" }}
          className="w-full max-w-xs bg-white rounded-[24px] p-5 border border-stone-200 shadow-sm text-left mb-12"
        >
          <div className="flex items-start gap-3">
            <Activity className="w-5 h-5 text-blue-500 shrink-0 mt-0.5" />
            <div>
              <h3 className="font-bold text-stone-800 text-sm mb-1">直前の状態を表示します</h3>
              <p className="text-xs text-stone-500 leading-relaxed">
                最後に取得したキャッシュデータを元に、あなたの軌跡を確認できます。
              </p>
            </div>
          </div>
        </motion.div>
      </div>

      <div className="p-6 mt-auto">
        <button 
          onClick={() => navigate(-1)}
          className="w-full py-4 rounded-full font-black tracking-widest text-sm bg-stone-900 text-white shadow-sm hover:bg-stone-800 active:scale-95 transition-all flex items-center justify-center gap-2"
        >
          <Globe2 className="w-4 h-4" />
          キャッシュデータを見る
        </button>
      </div>
    </div>
  );
}