import { useState } from "react";
import { useNavigate } from "react-router";
import { ArrowLeft, Sparkles, TrendingUp, Calendar, CheckSquare, Target, CheckCircle2, HeartHandshake, AlertCircle } from "lucide-react";
import { motion, AnimatePresence } from "motion/react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function WeeklyReport() {
  const navigate = useNavigate();
  // WeeklyReport screen for reviewing past actions
  const [showFeedbackModal, setShowFeedbackModal] = useState(false);
  const [feedbackSaved, setFeedbackSaved] = useState(false);

  const handleFeedbackSubmit = () => {
    setFeedbackSaved(true);
    setTimeout(() => {
      setShowFeedbackModal(false);
      setFeedbackSaved(false);
    }, 1500);
  };

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-hidden relative font-sans">
      <div className="pt-16 px-6 pb-4 bg-white border-b border-stone-200 z-10 sticky top-0 flex items-center justify-between shadow-sm">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-100 transition-colors">
          <ArrowLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="text-lg font-black text-stone-800 flex items-center gap-2">
          <Sparkles className="w-5 h-5 text-indigo-500" />
          今週の振り返り
        </div>
        <div className="w-10" />
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-6 pb-32">
        {/* Header Summary */}
        <div className="text-center mb-8">
          <p className="text-sm font-bold text-stone-500 tracking-widest uppercase mb-2">WEEKLY REPORT</p>
          <h1 className="text-2xl font-black text-stone-800 mb-4">
            今週のあなたの達成度は<br />
            <span className="text-indigo-600 text-4xl inline-block mt-2">82%</span> です！
          </h1>
          <p className="text-sm text-stone-600 leading-relaxed px-4 break-keep">
            素晴らしい1週間でした！仕事とプライベートのバランスが良く、多くの目標に着実な進捗が見られました。
          </p>
        </div>

        {/* Category Analysis */}
        <h2 className="text-lg font-black text-stone-800 mb-4 px-2">カテゴリ別分析</h2>
        
        <div className="space-y-4 mb-8">
          {/* Success Category */}
          <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-200 relative overflow-hidden">
            <div className="absolute top-0 left-0 w-2 h-full bg-emerald-400" />
            <div className="flex justify-between items-start mb-3">
              <div className="flex items-center gap-2">
                <Target className="w-5 h-5 text-emerald-500" />
                <h3 className="font-bold text-stone-800">教養・学習</h3>
              </div>
              <span className="bg-emerald-100 text-emerald-700 text-xs font-bold px-2 py-1 rounded-lg flex items-center gap-1">
                <TrendingUp className="w-3 h-3" /> 達成
              </span>
            </div>
            <p className="text-xs text-stone-600 leading-relaxed mb-4 break-keep">
              カレンダーに確保した時間をフル活用し、集中して取り組めました。このペースを維持しましょう！
            </p>
            <div className="grid grid-cols-2 gap-3 bg-stone-50 p-3 rounded-xl border border-stone-100">
              <div>
                <p className="text-[10px] text-stone-400 font-bold mb-1 flex items-center gap-1"><Calendar className="w-3 h-3" /> 確保時間</p>
                <p className="text-sm font-black text-stone-800">4.5<span className="text-[10px] text-stone-500 font-bold ml-1">h</span></p>
              </div>
              <div>
                <p className="text-[10px] text-stone-400 font-bold mb-1 flex items-center gap-1"><CheckSquare className="w-3 h-3" /> 実際の行動</p>
                <p className="text-sm font-black text-emerald-600">4.5<span className="text-[10px] text-emerald-500 font-bold ml-1">h</span></p>
              </div>
            </div>
          </div>

          {/* Needs Attention Category */}
          <div className="bg-white rounded-[24px] p-5 shadow-sm border border-stone-200 relative overflow-hidden">
            <div className="absolute top-0 left-0 w-2 h-full bg-amber-400" />
            <div className="flex justify-between items-start mb-3">
              <div className="flex items-center gap-2">
                <Target className="w-5 h-5 text-amber-500" />
                <h3 className="font-bold text-stone-800">健康・体力</h3>
              </div>
              <span className="bg-amber-50 text-amber-700 text-xs font-bold px-2 py-1 rounded-lg flex items-center gap-1">
                <AlertCircle className="w-3 h-3" /> 未達成
              </span>
            </div>
            
            <p className="text-xs text-stone-600 leading-relaxed mb-4 break-keep">
              忙しい1週間の中で、0.5時間だけでも「ランニング」の時間を作れたのは素晴らしい一歩です。自分の体を労わる時間を、少しずつ見つけていけるといいですね。
            </p>
            
            <div className="grid grid-cols-2 gap-3 bg-stone-50 p-3 rounded-xl border border-stone-100 mb-4">
              <div>
                <p className="text-[10px] text-stone-400 font-bold mb-1 flex items-center gap-1"><Calendar className="w-3 h-3" /> 確保時間</p>
                <p className="text-sm font-black text-stone-800">2.0<span className="text-[10px] text-stone-500 font-bold ml-1">h</span></p>
              </div>
              <div>
                <p className="text-[10px] text-stone-400 font-bold mb-1 flex items-center gap-1"><CheckSquare className="w-3 h-3" /> 実際の行動</p>
                <p className="text-sm font-black text-amber-600">0.5<span className="text-[10px] text-amber-500 font-bold ml-1">h</span></p>
              </div>
            </div>

            <button 
              onClick={() => setShowFeedbackModal(true)}
              className="w-full py-2.5 bg-amber-50 hover:bg-amber-100 text-amber-700 font-bold text-xs rounded-xl flex items-center justify-center gap-1.5 transition-colors border border-amber-200"
            >
              <HeartHandshake className="w-4 h-4" /> 状況を振り返る
            </button>
          </div>
        </div>

        {/* Recommendations */}
        <div className="bg-indigo-50 rounded-[24px] p-6 shadow-sm border border-indigo-100 mb-8">
          <h3 className="font-black text-indigo-900 mb-2 flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-indigo-500" />
            来週へのアドバイス
          </h3>
          <p className="text-sm text-indigo-800/80 leading-relaxed break-keep mb-4">
            「健康」を大切にしたいという素敵な思いが伝わってきます。毎日忙しいかと思いますが、まずは週に1回、30分だけ「自分の身体を労わる時間」をカレンダーに予約してみませんか？
          </p>
          <button 
            onClick={() => navigate('/time-allocation')}
            className="w-full py-3 bg-white text-indigo-600 font-bold text-sm rounded-xl flex items-center justify-center shadow-sm hover:shadow-md transition-shadow"
          >
            時間資源の配分を見直す
          </button>
        </div>

        {/* Goal Review CTA */}
        <div className="text-center px-4">
          <p className="text-xs font-bold text-stone-500 mb-3 break-keep">
            今の自分に合わせて、目標を調整することも大切です。
          </p>
          <button 
            onClick={() => navigate('/app/goal-review')}
            className="w-full py-4 bg-stone-800 text-white font-bold text-sm rounded-xl flex items-center justify-center shadow-sm hover:bg-stone-700 transition-colors"
          >
            <Target className="w-4 h-4 mr-2" />
            目標を見直す
          </button>
        </div>

      </div>

      {/* Feedback Modal */}
      <AnimatePresence>
        {showFeedbackModal && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="absolute inset-0 z-50 flex items-center justify-center p-6 bg-stone-900/60 backdrop-blur-sm"
            onClick={() => setShowFeedbackModal(false)}
          >
            <motion.div
              initial={{ scale: 0.95, y: 20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.95, y: 20 }}
              onClick={(e) => e.stopPropagation()}
              className="w-full max-w-sm bg-white rounded-[32px] p-6 shadow-2xl relative overflow-hidden"
            >
              <div className="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center mb-4 text-amber-600">
                <HeartHandshake className="w-6 h-6" />
              </div>
              <h3 className="text-xl font-black text-stone-800 mb-2">何か困ったことはありましたか？</h3>
              <p className="text-sm text-stone-500 leading-relaxed mb-6 break-keep">
                予定通りにいかないことも、もちろんあります。全く気にする必要はありません！今後のために、もしよければ今の状況や気持ちを少しだけ教えてくれませんか？
              </p>

              {!feedbackSaved ? (
                <div className="space-y-3">
                  <button onClick={handleFeedbackSubmit} className="w-full text-left px-4 py-3 bg-stone-50 hover:bg-stone-100 border border-stone-200 rounded-xl text-sm font-bold text-stone-700 transition-colors">
                    急な仕事や用事が入った
                  </button>
                  <button onClick={handleFeedbackSubmit} className="w-full text-left px-4 py-3 bg-stone-50 hover:bg-stone-100 border border-stone-200 rounded-xl text-sm font-bold text-stone-700 transition-colors">
                    モチベーションが上がらなかった
                  </button>
                  <button onClick={handleFeedbackSubmit} className="w-full text-left px-4 py-3 bg-stone-50 hover:bg-stone-100 border border-stone-200 rounded-xl text-sm font-bold text-stone-700 transition-colors">
                    予定を忘れていた
                  </button>
                  <button onClick={handleFeedbackSubmit} className="w-full text-left px-4 py-3 bg-stone-50 hover:bg-stone-100 border border-stone-200 rounded-xl text-sm font-bold text-stone-700 transition-colors">
                    体調が優れなかった
                  </button>
                </div>
              ) : (
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="bg-emerald-50 p-4 rounded-xl border border-emerald-100 flex flex-col items-center justify-center py-6"
                >
                  <div className="w-10 h-10 bg-emerald-100 rounded-full flex items-center justify-center text-emerald-600 mb-3">
                    <CheckCircle2 className="w-6 h-6" />
                  </div>
                  <p className="text-sm font-bold text-emerald-800 text-center break-keep">
                    教えていただきありがとうございます！<br />
                    焦る必要はありません。今のあなたのペースで、少しずつ進んでいきましょう。
                  </p>
                </motion.div>
              )}

              <button
                onClick={() => setShowFeedbackModal(false)}
                className="w-full mt-6 py-3.5 bg-stone-100 text-stone-600 font-bold rounded-xl hover:bg-stone-200 transition-colors"
              >
                閉じる
              </button>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
