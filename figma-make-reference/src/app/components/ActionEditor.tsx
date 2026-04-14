import { useState } from "react";
import { ChevronLeft, Target, Calendar, CheckCircle2, ChevronDown, ListTodo, Focus } from "lucide-react";
import { useNavigate } from "react-router";

export function ActionEditor() {
  const navigate = useNavigate();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [frequency, setFrequency] = useState("daily"); // daily, weekly, once

  const handleSave = () => {
    // 擬似的な保存処理
    navigate(-1);
  };

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-y-auto font-sans">
      {/* Header */}
      <div className="flex items-center justify-between p-6 pt-16 bg-white/80 backdrop-blur-md sticky top-0 z-20 border-b border-stone-200">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-100 transition-colors">
          <ChevronLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="font-bold text-stone-800 tracking-tight text-sm uppercase">
          アクションの追加
        </div>
        <div className="w-10"></div>
      </div>

      <div className="px-6 py-8 flex flex-col gap-8">
        
        {/* Title & Goal Target */}
        <div className="space-y-4">
          <div className="flex items-center gap-2 bg-stone-100 text-stone-500 text-xs font-bold px-3 py-1.5 rounded-full w-fit">
            <Target className="w-3.5 h-3.5" />
            <span>対象マス: 健康管理</span>
          </div>
          
          <input
            type="text"
            placeholder="具体的な行動を入力..."
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            className="w-full bg-transparent text-2xl font-black text-stone-900 placeholder:text-stone-300 outline-none border-b border-stone-200 focus:border-stone-400 pb-2 transition-colors"
            autoFocus
          />
        </div>

        {/* Options */}
        <div className="bg-white rounded-3xl p-2 border border-stone-200 shadow-sm">
          
          <div className="flex flex-col gap-1 p-4 border-b border-stone-100">
            <div className="flex items-center justify-between">
               <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                 <div className="w-8 h-8 rounded-full bg-stone-100 text-stone-500 flex items-center justify-center">
                   <Calendar className="w-4 h-4" />
                 </div>
                 頻度
               </div>
               
               <div className="flex bg-stone-100 p-1 rounded-full relative">
                 <button 
                   onClick={() => setFrequency("once")}
                   className={`relative z-10 px-4 py-1.5 text-[10px] font-bold rounded-full transition-colors ${frequency === "once" ? "text-white" : "text-stone-500 hover:text-stone-700"}`}
                 >
                   1回のみ
                 </button>
                 <button 
                   onClick={() => setFrequency("daily")}
                   className={`relative z-10 px-4 py-1.5 text-[10px] font-bold rounded-full transition-colors ${frequency === "daily" ? "text-white" : "text-stone-500 hover:text-stone-700"}`}
                 >
                   毎日
                 </button>
                 <button 
                   onClick={() => setFrequency("weekly")}
                   className={`relative z-10 px-4 py-1.5 text-[10px] font-bold rounded-full transition-colors ${frequency === "weekly" ? "text-white" : "text-stone-500 hover:text-stone-700"}`}
                 >
                   週次
                 </button>

                 {/* Active background indicator */}
                 <div 
                   className={`absolute top-1 bottom-1 bg-stone-800 rounded-full transition-all duration-300 ease-spring`}
                   style={{
                     left: frequency === "once" ? "4px" : frequency === "daily" ? "72px" : "128px",
                     width: frequency === "once" ? "68px" : frequency === "daily" ? "56px" : "56px"
                   }}
                 />
               </div>
            </div>
          </div>

          <div className="flex flex-col gap-1 p-4">
             <div className="flex items-center justify-between mb-2">
               <div className="flex items-center gap-3 text-sm font-bold text-stone-800">
                 <div className="w-8 h-8 rounded-full bg-stone-100 text-stone-500 flex items-center justify-center">
                   <ListTodo className="w-4 h-4" />
                 </div>
                 詳細メモ（任意）
               </div>
             </div>
             <textarea
               value={description}
               onChange={(e) => setDescription(e.target.value)}
               placeholder="いつ、どこで、どのように実行するか..."
               className="w-full bg-stone-50 rounded-2xl p-4 text-sm text-stone-700 placeholder:text-stone-400 outline-none border border-transparent focus:border-stone-200 resize-none min-h-[100px] transition-colors"
             />
          </div>
        </div>

        {/* Suggestion Card */}
        <div className="bg-gradient-to-br from-indigo-50 to-blue-50 rounded-3xl p-6 border border-indigo-100 flex gap-4 mt-4">
           <Focus className="w-6 h-6 text-indigo-500 shrink-0 mt-1" />
           <div>
             <h3 className="font-bold text-indigo-900 text-sm mb-1">小さく始めるのがコツです</h3>
             <p className="text-indigo-700/80 text-xs leading-relaxed">
               目標を達成するためには、「絶対に失敗しない」くらい小さな行動から始めるのがオススメです。
             </p>
           </div>
        </div>
      </div>

      {/* Floating Action Button */}
      <div className="mt-auto p-6 pb-12">
        <button 
          onClick={handleSave}
          disabled={!title.trim()}
          className={`w-full py-4 rounded-full font-black tracking-widest text-sm transition-all shadow-sm flex items-center justify-center gap-2 ${title.trim() ? "bg-stone-900 text-white hover:bg-stone-800 active:scale-95" : "bg-stone-200 text-stone-400 cursor-not-allowed"}`}
        >
          <CheckCircle2 className="w-5 h-5" />
          アクションを追加
        </button>
      </div>
    </div>
  );
}