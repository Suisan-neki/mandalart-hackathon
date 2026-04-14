import { useNavigate } from "react-router";
import { ArrowLeft, RefreshCw, ShieldAlert, AlertCircle, CloudOff, ChevronRight } from "lucide-react";
import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import { ApiErrorState, OfflineBanner } from "./Resilience";

export function ErrorDemo() {
  const navigate = useNavigate();
  const [isOffline, setIsOffline] = useState(false);

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 relative font-sans">
      <OfflineBanner isOffline={isOffline} />

      <div className="pt-16 px-6 pb-4 flex items-center justify-between z-10 sticky top-0 bg-stone-50/90 backdrop-blur-md">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-200 transition-colors">
          <ArrowLeft className="w-6 h-6 text-stone-600" />
        </button>
        <div className="font-bold text-stone-800 tracking-tight text-sm">エラー / 障害状態の確認</div>
        <div className="w-10" />
      </div>

      <div className="flex-1 p-6 overflow-y-auto space-y-6 pb-32">
        <div className="bg-white rounded-3xl p-5 border border-stone-200 shadow-sm space-y-3">
          <h3 className="font-bold text-sm text-stone-800 mb-2">個別エラー画面への遷移</h3>
          
          <button 
            onClick={() => navigate("/app/error-demo/rate-limit")}
            className="w-full p-3 rounded-xl flex items-center justify-between text-left transition-colors border bg-white border-stone-100 hover:bg-amber-50 group"
          >
            <div className="flex items-center gap-3">
              <RefreshCw className="w-5 h-5 text-amber-500" />
              <div>
                <div className="font-bold text-sm text-stone-800">レートリミット超過</div>
                <div className="text-xs text-stone-500">API呼び出し制限の画面</div>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-stone-300 group-hover:text-amber-500" />
          </button>

          <button 
            onClick={() => navigate("/app/error-demo/auth")}
            className="w-full p-3 rounded-xl flex items-center justify-between text-left transition-colors border bg-white border-stone-100 hover:bg-red-50 group"
          >
            <div className="flex items-center gap-3">
              <ShieldAlert className="w-5 h-5 text-red-500" />
              <div>
                <div className="font-bold text-sm text-stone-800">認証エラー</div>
                <div className="text-xs text-stone-500">トークン期限切れ等の画面</div>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-stone-300 group-hover:text-red-500" />
          </button>

          <button 
            onClick={() => navigate("/app/error-demo/unknown")}
            className="w-full p-3 rounded-xl flex items-center justify-between text-left transition-colors border bg-white border-stone-100 hover:bg-stone-100 group"
          >
            <div className="flex items-center gap-3">
              <AlertCircle className="w-5 h-5 text-stone-600" />
              <div>
                <div className="font-bold text-sm text-stone-800">サーバー・不明なエラー</div>
                <div className="text-xs text-stone-500">サーバーダウン等の画面</div>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-stone-300 group-hover:text-stone-600" />
          </button>
          
          <button 
            onClick={() => navigate("/app/error-demo/offline")}
            className="w-full p-3 rounded-xl flex items-center justify-between text-left transition-colors border bg-white border-stone-100 hover:bg-blue-50 group"
          >
            <div className="flex items-center gap-3">
              <CloudOff className="w-5 h-5 text-blue-500" />
              <div>
                <div className="font-bold text-sm text-stone-800">オフライン（フルスクリーン）</div>
                <div className="text-xs text-stone-500">ネットワーク切断時の画面</div>
              </div>
            </div>
            <ChevronRight className="w-4 h-4 text-stone-300 group-hover:text-blue-500" />
          </button>

          <div className="pt-4 mt-2 border-t border-stone-100">
            <h3 className="font-bold text-sm text-stone-800 mb-3">オーバーレイ表示のテスト</h3>
            <button 
              onClick={() => setIsOffline(!isOffline)}
              className={`w-full p-3 rounded-xl flex items-center gap-3 text-left transition-colors border ${isOffline ? "bg-stone-800 border-stone-700 text-white" : "bg-white border-stone-100 hover:bg-stone-50 text-stone-800"}`}
            >
              <CloudOff className={`w-5 h-5 ${isOffline ? "text-stone-300" : "text-stone-400"}`} />
              <div>
                <div className="font-bold text-sm">オフラインバナーの切り替え</div>
                <div className={`text-xs ${isOffline ? "text-stone-400" : "text-stone-500"}`}>画面上部からのスライドダウン</div>
              </div>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}