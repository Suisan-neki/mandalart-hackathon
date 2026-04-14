import { useState } from "react";
import { useNavigate, useLocation } from "react-router";
import { ArrowLeft, Calendar, Clock, Plus, Target, Check, AlertCircle, Link2, Sparkles, ChevronRight } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const colorMap = {
  blue: { bg: "bg-blue-50", text: "text-blue-600", bar: "bg-blue-500", border: "border-blue-200" },
  emerald: { bg: "bg-emerald-50", text: "text-emerald-600", bar: "bg-emerald-500", border: "border-emerald-200" },
  amber: { bg: "bg-amber-50", text: "text-amber-600", bar: "bg-amber-500", border: "border-amber-200" },
  rose: { bg: "bg-rose-50", text: "text-rose-600", bar: "bg-rose-500", border: "border-rose-200" },
};

export function TimeAllocation() {
  const navigate = useNavigate();
  // TimeAllocation screen for managing calendar integration
  const location = useLocation();
  const state = location.state as { selectedCategory?: any, selectedBlock?: any } | null;

  const [showEventModal, setShowEventModal] = useState(!!state?.selectedBlock);
  const [eventTitle, setEventTitle] = useState(state?.selectedBlock?.title || "");
  const [eventDate, setEventDate] = useState("2026-04-15");
  const [eventTime, setEventTime] = useState("10:00");
  const [eventDuration, setEventDuration] = useState("1");
  const [saved, setSaved] = useState(false);

  const [suggestions, setSuggestions] = useState([
    { id: 1, title: "ジムでトレーニング", time: "水曜 19:00 (1.5h)", targetCategory: "健康・体力", targetGoal: "週3回の運動", color: "emerald", accepted: false },
    { id: 2, title: "デザインパターンの読書", time: "木曜 21:00 (1h)", targetCategory: "教養・学習", targetGoal: "専門書の読破", color: "blue", accepted: false },
  ]);

  const handleSaveEvent = () => {
    setSaved(true);
    setTimeout(() => {
      setShowEventModal(false);
      setSaved(false);
    }, 1500);
  };

  const handleAcceptSuggestion = (id: number) => {
    setSuggestions(prev => prev.map(s => s.id === id ? { ...s, accepted: true } : s));
  };

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-hidden relative font-sans">
      <div className="pt-16 px-6 pb-4 bg-white border-b border-stone-200 z-10 sticky top-0 flex items-center justify-between shadow-sm">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-100 transition-colors">
          <ArrowLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="text-lg font-black text-stone-800 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-indigo-500" />
          時間資源の配分
        </div>
        <div className="w-10" />
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-6 pb-32">
        {/* Dashboard Overview */}
        <div className="bg-white rounded-[24px] p-6 shadow-sm border border-stone-100 mb-8">
          <h2 className="text-sm font-bold text-stone-500 uppercase tracking-widest mb-6">今週の確保時間</h2>
          
          <div className="space-y-6">
            <div className="space-y-2">
              <div className="flex justify-between items-end">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-blue-500" />
                  <span className="font-bold text-stone-800">仕事・キャリア</span>
                </div>
                <div className="text-right">
                  <span className="text-xl font-black text-stone-800">12.5<span className="text-xs text-stone-500 font-bold ml-1">h</span></span>
                </div>
              </div>
              <div className="w-full h-3 bg-stone-100 rounded-full overflow-hidden">
                <div className="h-full bg-blue-500 rounded-full" style={{ width: '60%' }} />
              </div>
              <p className="text-xs text-stone-500">十分な時間が確保されています</p>
            </div>

            <div className="space-y-2">
              <div className="flex justify-between items-end">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-emerald-500" />
                  <span className="font-bold text-stone-800">健康・体力</span>
                </div>
                <div className="text-right">
                  <span className="text-xl font-black text-stone-800">1.5<span className="text-xs text-stone-500 font-bold ml-1">h</span></span>
                </div>
              </div>
              <div className="w-full h-3 bg-stone-100 rounded-full overflow-hidden">
                <div className="h-full bg-emerald-500 rounded-full" style={{ width: '20%' }} />
              </div>
              <div className="flex items-start gap-1.5 mt-1 bg-amber-50 text-amber-700 p-2 rounded-lg">
                <AlertCircle className="w-3.5 h-3.5 shrink-0 mt-0.5" />
                <p className="text-xs font-medium leading-relaxed">
                  「健康」を大切にするための時間を、あと2.5時間ほど作れると理想的ですね。無理のない範囲で、カレンダーに少し予定を置いてみませんか？
                </p>
              </div>
              <button 
                onClick={() => setShowEventModal(true)}
                className="mt-2 w-full py-2 bg-emerald-50 text-emerald-700 font-bold text-sm rounded-xl hover:bg-emerald-100 transition-colors flex items-center justify-center gap-1.5"
              >
                <Plus className="w-4 h-4" /> カレンダーに予定を追加
              </button>
            </div>

            <div className="space-y-2">
              <div className="flex justify-between items-end">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded-full bg-rose-500" />
                  <span className="font-bold text-stone-800">人間関係</span>
                </div>
                <div className="text-right">
                  <span className="text-xl font-black text-stone-800">3.0<span className="text-xs text-stone-500 font-bold ml-1">h</span></span>
                </div>
              </div>
              <div className="w-full h-3 bg-stone-100 rounded-full overflow-hidden">
                <div className="h-full bg-rose-500 rounded-full" style={{ width: '40%' }} />
              </div>
              <p className="text-xs text-stone-500">順調に時間が配分されています</p>
            </div>
          </div>
        </div>

        {/* Smart Suggestions */}
        <h3 className="text-lg font-black text-stone-800 mb-4 flex items-center gap-2">
          <Sparkles className="w-5 h-5 text-amber-500" />
          予定の自動紐付け提案
        </h3>
        <p className="text-sm text-stone-500 mb-4 leading-relaxed">
          Googleカレンダーの予定から、あなたの目標に関連しそうなものを提案しています。承認すると目標と連携されます。
        </p>

        <div className="space-y-3 mb-8">
          {suggestions.map(suggestion => (
            <AnimatePresence key={suggestion.id}>
              {!suggestion.accepted && (
                <motion.div
                  initial={{ opacity: 1, height: "auto" }}
                  exit={{ opacity: 0, height: 0, marginBottom: 0 }}
                  className="bg-white rounded-2xl p-4 border border-stone-200 shadow-sm"
                >
                  <div className="flex items-start gap-3">
                    <div className={cn("p-2 rounded-xl shrink-0", colorMap[suggestion.color as keyof typeof colorMap].bg)}>
                      <Calendar className={cn("w-5 h-5", colorMap[suggestion.color as keyof typeof colorMap].text)} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h4 className="font-bold text-stone-800 text-sm truncate">{suggestion.title}</h4>
                      <p className="text-xs text-stone-500 flex items-center gap-1 mt-1">
                        <Clock className="w-3 h-3" /> {suggestion.time}
                      </p>
                      
                      <div className="mt-3 bg-stone-50 p-2.5 rounded-xl border border-stone-100">
                        <p className="text-[10px] text-stone-400 font-bold mb-1 uppercase tracking-widest">関連する目標</p>
                        <div className="flex items-center gap-1.5">
                          <Target className={cn("w-3.5 h-3.5", colorMap[suggestion.color as keyof typeof colorMap].text)} />
                          <span className="text-xs font-bold text-stone-700">{suggestion.targetCategory}</span>
                          <ChevronRight className="w-3 h-3 text-stone-400" />
                          <span className="text-xs font-medium text-stone-600">{suggestion.targetGoal}</span>
                        </div>
                      </div>

                      <div className="flex gap-2 mt-3">
                        <button 
                          onClick={() => handleAcceptSuggestion(suggestion.id)}
                          className="flex-1 py-2 bg-stone-800 text-white text-xs font-bold rounded-lg hover:bg-stone-700 transition-colors"
                        >
                          承認して紐付ける
                        </button>
                        <button className="px-3 py-2 bg-stone-100 text-stone-500 text-xs font-bold rounded-lg hover:bg-stone-200 transition-colors">
                          修正
                        </button>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          ))}
          {suggestions.every(s => s.accepted) && (
            <div className="bg-stone-50 rounded-2xl p-6 border border-stone-200 text-center text-stone-500 text-sm">
              すべての提案を確認しました 🎉
            </div>
          )}
        </div>

      </div>

      {/* Quick Event Modal */}
      <AnimatePresence>
        {showEventModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 backdrop-blur-sm sm:p-6"
            onClick={() => setShowEventModal(false)}
          >
            <motion.div
              initial={{ y: "100%" }}
              animate={{ y: 0 }}
              exit={{ y: "100%" }}
              transition={{ type: "spring", damping: 25, stiffness: 200 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full sm:max-w-sm bg-white sm:rounded-[32px] rounded-t-[32px] p-6 shadow-2xl pb-10 sm:pb-6"
            >
              <div className="w-12 h-1.5 bg-stone-200 rounded-full mx-auto mb-6 sm:hidden" />
              
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-xl font-black text-stone-800 flex items-center gap-2">
                  <Calendar className="w-5 h-5 text-indigo-500" />
                  カレンダーに時間を確保
                </h3>
              </div>

              {state?.selectedBlock && (
                <div className="mb-6 bg-indigo-50 p-4 rounded-2xl border border-indigo-100">
                  <p className="text-[10px] text-indigo-500 font-bold mb-1 uppercase tracking-widest">紐付ける目標</p>
                  <div className="flex items-center gap-2 text-indigo-900 font-bold">
                    <Link2 className="w-4 h-4" />
                    {state.selectedBlock.title}
                  </div>
                </div>
              )}

              <div className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-stone-500 mb-1.5">予定のタイトル</label>
                  <input 
                    type="text" 
                    value={eventTitle}
                    onChange={(e) => setEventTitle(e.target.value)}
                    className="w-full px-4 py-3 bg-stone-50 border border-stone-200 rounded-xl text-stone-800 font-bold focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
                    placeholder="例: ジムに行く"
                  />
                </div>
                
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-stone-500 mb-1.5">日付</label>
                    <input 
                      type="date" 
                      value={eventDate}
                      onChange={(e) => setEventDate(e.target.value)}
                      className="w-full px-4 py-3 bg-stone-50 border border-stone-200 rounded-xl text-stone-800 font-bold focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-stone-500 mb-1.5">開始時間</label>
                    <input 
                      type="time" 
                      value={eventTime}
                      onChange={(e) => setEventTime(e.target.value)}
                      className="w-full px-4 py-3 bg-stone-50 border border-stone-200 rounded-xl text-stone-800 font-bold focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-bold text-stone-500 mb-1.5">確保する時間（時間）</label>
                  <select 
                    value={eventDuration}
                    onChange={(e) => setEventDuration(e.target.value)}
                    className="w-full px-4 py-3 bg-stone-50 border border-stone-200 rounded-xl text-stone-800 font-bold focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 transition-all appearance-none"
                  >
                    <option value="0.5">30分</option>
                    <option value="1">1時間</option>
                    <option value="1.5">1.5時間</option>
                    <option value="2">2時間</option>
                    <option value="3">3時間</option>
                  </select>
                </div>
              </div>

              <div className="mt-8 flex gap-3">
                <button 
                  onClick={() => setShowEventModal(false)}
                  className="flex-1 py-3.5 bg-stone-100 text-stone-600 font-bold rounded-xl hover:bg-stone-200 transition-colors"
                >
                  キャンセル
                </button>
                <button 
                  onClick={handleSaveEvent}
                  disabled={saved}
                  className="flex-1 py-3.5 bg-indigo-600 text-white font-bold rounded-xl hover:bg-indigo-500 transition-colors flex items-center justify-center gap-2"
                >
                  {saved ? (
                    <><Check className="w-5 h-5" /> 確保しました</>
                  ) : (
                    <><Calendar className="w-5 h-5" /> カレンダーに追加</>
                  )}
                </button>
              </div>

            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
