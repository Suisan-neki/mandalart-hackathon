import { useState } from "react";
import { useNavigate } from "react-router";
import { Github, Calendar, CheckCircle2, ChevronRight, Lock } from "lucide-react";
import { motion } from "motion/react";

export function Integrations() {
  const navigate = useNavigate();
  const [githubConnected, setGithubConnected] = useState(false);
  const [calendarConnected, setCalendarConnected] = useState(false);

  const handleNext = () => {
    navigate("/mandalart-input");
  };

  return (
    <div className="flex h-full w-full flex-col bg-stone-50 text-stone-900 p-6 relative overflow-hidden font-sans">
      <div className="mt-16 mb-8">
        <h1 className="text-3xl font-black mb-3 text-stone-800">データを連携する</h1>
        <p className="text-stone-500 text-sm leading-relaxed">
          Mandalart Syncは、あなたの自己認識と実際の行動ログを同期（Sync）し、無理のない目標達成をサポートします。
        </p>
      </div>

      <div className="flex-1 space-y-4 w-full max-w-sm mx-auto">
        {/* GitHub Integration */}
        <div
          className={`p-5 rounded-2xl border transition-all duration-300 ${
            githubConnected
              ? "bg-white border-green-500 shadow-sm"
              : "bg-white border-stone-200 hover:border-stone-300 shadow-sm"
          }`}
        >
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-stone-900 text-white flex items-center justify-center">
                <Github className="w-6 h-6" />
              </div>
              <div>
                <h3 className="font-bold text-stone-800">GitHub</h3>
                <p className="text-xs text-stone-500">コミットログを解析</p>
              </div>
            </div>
            {githubConnected ? (
              <CheckCircle2 className="text-green-500 w-6 h-6" />
            ) : (
              <button
                onClick={() => setGithubConnected(true)}
                className="px-4 py-2 bg-stone-100 text-stone-700 text-xs font-bold rounded-full hover:bg-stone-200 transition-colors active:scale-95"
              >
                連携する
              </button>
            )}
          </div>
          <p className="text-xs text-stone-400 border-t border-stone-100 pt-3 flex items-center gap-2">
            <Lock className="w-3 h-3" /> 読み取り専用で安全に連携
          </p>
        </div>

        {/* Google Calendar Integration */}
        <div
          className={`p-5 rounded-2xl border transition-all duration-300 ${
            calendarConnected
              ? "bg-white border-green-500 shadow-sm"
              : "bg-white border-stone-200 hover:border-stone-300 shadow-sm"
          }`}
        >
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-600 flex items-center justify-center">
                <Calendar className="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 className="font-bold text-stone-800">Google Calendar</h3>
                <p className="text-xs text-stone-500">スケジュール実行率</p>
              </div>
            </div>
            {calendarConnected ? (
              <CheckCircle2 className="text-green-500 w-6 h-6" />
            ) : (
              <button
                onClick={() => setCalendarConnected(true)}
                className="px-4 py-2 bg-stone-100 text-stone-700 text-xs font-bold rounded-full hover:bg-stone-200 transition-colors active:scale-95"
              >
                連携する
              </button>
            )}
          </div>
          <p className="text-xs text-stone-400 border-t border-stone-100 pt-3 flex items-center gap-2">
            <Lock className="w-3 h-3" /> イベント履歴のみ取得
          </p>
        </div>
      </div>

      <div className="w-full pb-10 flex flex-col items-center pt-6">
        <motion.button
          whileTap={{ scale: 0.95 }}
          onClick={handleNext}
          className="w-full max-w-sm h-14 bg-amber-500 text-white font-bold rounded-2xl flex items-center justify-center gap-2 shadow-lg shadow-amber-500/20 hover:bg-amber-600 transition-colors"
        >
          <span>{githubConnected || calendarConnected ? "次へ進む" : "スキップして後で設定"}</span>
          <ChevronRight className="w-5 h-5" />
        </motion.button>
        {!githubConnected && !calendarConnected && (
           <p className="text-xs text-stone-400 mt-4 text-center">
            ※連携しない場合、手動入力のみで同期されます
          </p>
        )}
      </div>
    </div>
  );
}
