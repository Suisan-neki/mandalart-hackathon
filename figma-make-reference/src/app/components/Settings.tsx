import { useState } from "react";
import { Github, Calendar, Bell, Shield, LogOut, ChevronRight, RefreshCw, Trash2 } from "lucide-react";
import { useNavigate } from "react-router";

export function Settings() {
  const [notifications, setNotifications] = useState(true);
  const navigate = useNavigate();

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-y-auto font-sans">
      <div className="pt-16 px-6 pb-6">
        <h1 className="text-2xl font-black text-stone-900 mb-8 tracking-tight">
          設定
        </h1>

        <div className="space-y-6">
          {/* Section: API */}
          <section>
            <h2 className="text-xs font-bold text-stone-500 uppercase tracking-widest mb-3 px-2">
              連携サービス
            </h2>
            <div className="bg-white rounded-[24px] border border-stone-200 overflow-hidden shadow-sm">
              <button 
                onClick={() => navigate("/app/sync-settings")}
                className="w-full flex items-center justify-between p-4 border-b border-stone-100 hover:bg-stone-50 transition-colors active:bg-stone-100"
              >
                <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                  <div className="w-8 h-8 rounded-full bg-stone-900 text-white flex items-center justify-center">
                    <Github className="w-4 h-4" />
                  </div>
                  GitHub (連携済み)
                </div>
                <ChevronRight className="w-5 h-5 text-stone-300" />
              </button>
              
              <button 
                onClick={() => navigate("/app/sync-settings")}
                className="w-full flex items-center justify-between p-4 hover:bg-stone-50 transition-colors active:bg-stone-100"
              >
                <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                  <div className="w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center">
                    <Calendar className="w-4 h-4" />
                  </div>
                  Google Calendar (未連携)
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[10px] text-red-500 font-bold bg-red-50 px-2 py-1 rounded-full">設定する</span>
                  <ChevronRight className="w-5 h-5 text-stone-300" />
                </div>
              </button>
            </div>
          </section>

          {/* Section: App */}
          <section>
            <h2 className="text-xs font-bold text-stone-500 uppercase tracking-widest mb-3 px-2">
              アプリ設定
            </h2>
            <div className="bg-white rounded-[24px] border border-stone-200 overflow-hidden shadow-sm">
              <div className="w-full flex items-center justify-between p-4 border-b border-stone-100">
                <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                  <div className="w-8 h-8 rounded-full bg-stone-100 text-stone-500 flex items-center justify-center">
                    <Bell className="w-4 h-4" />
                  </div>
                  リマインド通知
                </div>
                <div 
                  onClick={() => setNotifications(!notifications)}
                  className={`w-12 h-6 rounded-full p-1 cursor-pointer transition-colors ${notifications ? "bg-red-500" : "bg-stone-300"}`}
                >
                  <div className={`w-4 h-4 rounded-full bg-white shadow-sm transition-transform ${notifications ? "translate-x-6" : "translate-x-0"}`} />
                </div>
              </div>
              
              <button className="w-full flex items-center justify-between p-4 hover:bg-stone-50 transition-colors active:bg-stone-100">
                <div className="flex items-center gap-3 text-sm font-bold text-red-600">
                  <div className="w-8 h-8 rounded-full bg-red-50 text-red-500 flex items-center justify-center">
                    <Trash2 className="w-4 h-4" />
                  </div>
                  すべてのデータをリセット
                </div>
              </button>
            </div>
          </section>

          {/* Section: Legal */}
          <section>
            <h2 className="text-xs font-bold text-stone-500 uppercase tracking-widest mb-3 px-2">
              その他
            </h2>
            <div className="bg-white rounded-[24px] border border-stone-200 overflow-hidden shadow-sm">
              <button className="w-full flex items-center justify-between p-4 border-b border-stone-100 hover:bg-stone-50 transition-colors active:bg-stone-100">
                <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                  <div className="w-8 h-8 rounded-full bg-stone-100 text-stone-500 flex items-center justify-center">
                    <Shield className="w-4 h-4" />
                  </div>
                  プライバシーポリシー
                </div>
                <ChevronRight className="w-5 h-5 text-stone-300" />
              </button>
              
              <button className="w-full flex items-center justify-between p-4 hover:bg-stone-50 transition-colors active:bg-stone-100">
                <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                  <div className="w-8 h-8 rounded-full bg-stone-100 text-stone-500 flex items-center justify-center">
                    <LogOut className="w-4 h-4" />
                  </div>
                  ログアウト
                </div>
                <ChevronRight className="w-5 h-5 text-stone-300" />
              </button>
            </div>
          </section>

          <div className="text-center text-stone-400 text-xs py-6">
            Mandalart Sync Version 1.0.0
          </div>
        </div>
      </div>
    </div>
  );
}
