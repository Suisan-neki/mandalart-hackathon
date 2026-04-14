import { motion, AnimatePresence } from "motion/react";
import { CloudOff, RefreshCw, AlertCircle, Wifi, ShieldAlert, X, CheckCircle2 } from "lucide-react";
import { useState, useEffect } from "react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// 1. Offline State Banner
export function OfflineBanner({ isOffline }: { isOffline: boolean }) {
  return (
    <AnimatePresence>
      {isOffline && (
        <motion.div
          initial={{ y: -100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: -100, opacity: 0 }}
          className="fixed top-0 left-0 right-0 z-50 p-4 pt-14"
        >
          <div className="bg-stone-800 text-white rounded-2xl shadow-xl p-4 flex items-start gap-4 border border-stone-700 pointer-events-auto">
            <div className="bg-stone-700 p-2 rounded-full mt-1">
              <CloudOff className="w-5 h-5 text-stone-300" />
            </div>
            <div className="flex-1">
              <h4 className="font-bold text-sm mb-1">オフラインです</h4>
              <p className="text-xs text-stone-400 leading-relaxed mb-2">
                最後に取得したデータ（キャッシュ）を表示しています。オンラインに復帰すると、自動的に最新の状態に同期されます。
              </p>
              <div className="flex items-center gap-1 text-[10px] text-stone-500 font-medium">
                <Wifi className="w-3 h-3" />
                Wi-Fi設定を確認してください
              </div>
            </div>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

// 2. API Error State Component
type ErrorType = "rate_limit" | "auth" | "unknown" | null;

export function ApiErrorState({ 
  errorType, 
  onRetry, 
  onClose 
}: { 
  errorType: ErrorType; 
  onRetry: () => void;
  onClose: () => void;
}) {
  if (!errorType) return null;

  const errorConfig = {
    rate_limit: {
      title: "GitHubが少しお休み中です",
      desc: "アクセスが集中しているため、一時的に連携をお休みしています。少し時間をおいてから、もう一度お試しください。",
      icon: <RefreshCw className="w-6 h-6 text-amber-500" />,
      bg: "bg-amber-50",
      border: "border-amber-200",
      buttonText: "再試行する",
    },
    auth: {
      title: "連携に問題が発生しました",
      desc: "セキュリティ保護のため、GitHubとの接続が切れています。お手数ですが、アカウントの連携を再設定してください。",
      icon: <ShieldAlert className="w-6 h-6 text-red-500" />,
      bg: "bg-red-50",
      border: "border-red-200",
      buttonText: "再連携する",
    },
    unknown: {
      title: "データの取得に失敗しました",
      desc: "予期せぬエラーが発生しました。ご迷惑をおかけして申し訳ありません。",
      icon: <AlertCircle className="w-6 h-6 text-stone-500" />,
      bg: "bg-stone-100",
      border: "border-stone-200",
      buttonText: "やり直す",
    }
  };

  const config = errorConfig[errorType];

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      className={cn("rounded-[32px] p-6 border relative overflow-hidden", config.bg, config.border)}
    >
      <button 
        onClick={onClose}
        className="absolute top-4 right-4 text-stone-400 hover:text-stone-600 transition-colors"
      >
        <X className="w-5 h-5" />
      </button>
      
      <div className="bg-white w-12 h-12 rounded-full flex items-center justify-center mb-4 shadow-sm">
        {config.icon}
      </div>
      <h3 className="font-bold text-stone-800 text-lg mb-2">{config.title}</h3>
      <p className="text-sm text-stone-600 mb-6 leading-relaxed">
        {config.desc}
      </p>
      
      <button
        onClick={onRetry}
        className="w-full py-3 bg-white border border-stone-200 rounded-xl font-bold text-sm text-stone-700 shadow-sm active:scale-95 transition-all hover:bg-stone-50"
      >
        {config.buttonText}
      </button>
    </motion.div>
  );
}

// 3. Data Syncing UI (Overlay)
export function SyncOverlay({ isSyncing, onComplete }: { isSyncing: boolean; onComplete?: () => void }) {
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    if (isSyncing) {
      setShowSuccess(false);
    } else if (!isSyncing && !showSuccess) {
      // Simulate success state for a moment before completely hiding if it was syncing
      // Wait, to keep it simple, we'll just handle it from the parent component.
    }
  }, [isSyncing]);

  return (
    <AnimatePresence>
      {isSyncing && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="fixed inset-0 z-50 flex items-center justify-center bg-stone-50/80 backdrop-blur-sm p-6"
        >
          <motion.div 
            initial={{ scale: 0.9 }}
            animate={{ scale: 1 }}
            className="bg-white rounded-[40px] shadow-2xl p-8 w-full max-w-sm text-center flex flex-col items-center relative overflow-hidden border border-stone-100"
          >
            {/* Animated overlapping circles representing Ideal and Reality syncing */}
            <div className="relative w-32 h-32 mb-8 flex items-center justify-center">
              <motion.div
                animate={{ 
                  x: [-20, 0, -20],
                  scale: [1, 1.1, 1],
                }}
                transition={{ 
                  repeat: Infinity, 
                  duration: 2,
                  ease: "easeInOut"
                }}
                className="absolute w-20 h-20 rounded-full border-[3px] border-amber-400 mix-blend-multiply opacity-80"
              />
              <motion.div
                animate={{ 
                  x: [20, 0, 20],
                  scale: [1, 1.1, 1],
                }}
                transition={{ 
                  repeat: Infinity, 
                  duration: 2,
                  ease: "easeInOut",
                  delay: 0.2
                }}
                className="absolute w-20 h-20 rounded-full border-[3px] border-stone-300 mix-blend-multiply opacity-80"
              />
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ repeat: Infinity, duration: 8, ease: "linear" }}
                className="absolute w-full h-full border border-dashed border-stone-200 rounded-full"
              />
              
              <div className="absolute inset-0 flex items-center justify-center">
                <RefreshCw className="w-6 h-6 text-amber-500 animate-spin" style={{ animationDuration: '3s' }} />
              </div>
            </div>

            <h3 className="text-xl font-black text-stone-800 mb-2 tracking-tight">
              データを同期中...
            </h3>
            <p className="text-sm text-stone-500 leading-relaxed">
              最新の行動ログを取得し、<br />あなたの目標の進捗に反映しています。
            </p>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
