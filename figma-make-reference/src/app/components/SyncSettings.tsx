import { useState } from "react";
import { ChevronLeft, Github, Calendar as CalendarIcon, Target, Search, MoreHorizontal, Settings, Plug, Zap } from "lucide-react";
import { useNavigate } from "react-router";

export function SyncSettings() {
  const navigate = useNavigate();
  const [githubSync, setGithubSync] = useState(true);
  const [calendarSync, setCalendarSync] = useState(false);
  const [notionSync, setNotionSync] = useState(false);

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-y-auto font-sans pb-24">
      {/* Header */}
      <div className="flex items-center justify-between p-6 pt-16 bg-white/80 backdrop-blur-md sticky top-0 z-20 border-b border-stone-200">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-100 transition-colors">
          <ChevronLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="font-bold text-stone-800 tracking-tight text-sm uppercase">
          同期サービス設定
        </div>
        <div className="w-10"></div>
      </div>

      {/* Hero Section */}
      <div className="px-6 py-8">
        <h1 className="text-2xl font-black text-stone-900 mb-2 tracking-tight">
          日常と目標をつなぐ
        </h1>
        <p className="text-stone-500 text-sm leading-relaxed">
          普段使っているツールと連携し、日々の行動を自動でマンダラートに同期させましょう。
        </p>
      </div>

      {/* Connected Services */}
      <div className="px-6 space-y-4">
        <h2 className="text-xs font-bold text-stone-400 uppercase tracking-widest px-2">
          連携済みのサービス
        </h2>

        {/* GitHub Integration */}
        <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-200 flex flex-col gap-4 transition-all">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-stone-900 text-white flex items-center justify-center">
                <Github className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-stone-800 text-sm">GitHub</h3>
                <p className="text-stone-400 text-xs">コミットを自動同期</p>
              </div>
            </div>
            <div 
              onClick={() => setGithubSync(!githubSync)}
              className={`w-12 h-6 rounded-full p-1 cursor-pointer transition-colors ${githubSync ? "bg-stone-900" : "bg-stone-200"}`}
            >
              <div className={`w-4 h-4 rounded-full bg-white shadow-sm transition-transform ${githubSync ? "translate-x-6" : "translate-x-0"}`} />
            </div>
          </div>
          
          {githubSync && (
            <div className="pt-4 border-t border-stone-100 flex items-center justify-between">
              <div className="flex items-center gap-2 text-xs text-stone-500">
                <Target className="w-4 h-4 text-stone-400" />
                <span>関連付け: <span className="font-bold text-stone-700">技術スキルの向上</span></span>
              </div>
              <button className="text-[10px] font-bold text-stone-600 bg-stone-100 px-3 py-1.5 rounded-full hover:bg-stone-200 transition-colors">
                変更
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Available Services */}
      <div className="px-6 space-y-4 mt-8">
        <h2 className="text-xs font-bold text-stone-400 uppercase tracking-widest px-2">
          連携可能なサービス
        </h2>

        {/* Google Calendar */}
        <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-200 flex flex-col gap-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center border border-blue-100">
                <CalendarIcon className="w-5 h-5" />
              </div>
              <div>
                <h3 className="font-bold text-stone-800 text-sm">Google Calendar</h3>
                <p className="text-stone-400 text-xs">完了した予定を記録</p>
              </div>
            </div>
            <button 
              onClick={() => setCalendarSync(true)}
              className="text-xs font-bold bg-blue-600 text-white px-4 py-2 rounded-full shadow-sm hover:bg-blue-700 active:scale-95 transition-all"
            >
              連携する
            </button>
          </div>
        </div>

        {/* Notion */}
        <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-200 flex flex-col gap-4 opacity-75">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-stone-100 text-stone-800 flex items-center justify-center border border-stone-200">
                <span className="font-serif font-bold">N</span>
              </div>
              <div>
                <h3 className="font-bold text-stone-800 text-sm">Notion</h3>
                <p className="text-stone-400 text-xs">完了したタスクを同期</p>
              </div>
            </div>
            <button 
              onClick={() => setNotionSync(true)}
              className="text-xs font-bold bg-stone-800 text-white px-4 py-2 rounded-full shadow-sm hover:bg-stone-900 active:scale-95 transition-all"
            >
              連携する
            </button>
          </div>
        </div>
      </div>

      <div className="px-6 mt-12 mb-8">
         <div className="bg-stone-100 rounded-3xl p-6 border border-stone-200 text-center">
            <Zap className="w-6 h-6 text-stone-400 mx-auto mb-3" />
            <p className="text-stone-500 text-xs leading-relaxed font-medium">
              自動同期を活用することで、入力の手間を省きながら「できたこと」を確実に積み上げられます。
            </p>
         </div>
      </div>
    </div>
  );
}