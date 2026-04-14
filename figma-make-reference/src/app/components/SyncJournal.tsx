import { useNavigate } from "react-router";
import { ChevronLeft, CheckCircle2, Github, Calendar as CalendarIcon, Target, Star } from "lucide-react";

const journalEntries = [
  {
    id: 1,
    time: "09:30",
    source: "GitHub",
    icon: Github,
    color: "bg-stone-900 text-white",
    action: "リポジトリにコミットしました",
    detail: "feat: add user authentication",
    targetGoal: "技術スキルの向上",
  },
  {
    id: 2,
    time: "12:00",
    source: "Google Calendar",
    icon: CalendarIcon,
    color: "bg-blue-600 text-white",
    action: "予定を完了しました",
    detail: "1on1 ミーティング",
    targetGoal: "チームとの信頼構築",
  },
  {
    id: 3,
    time: "15:45",
    source: "Manual",
    icon: CheckCircle2,
    color: "bg-green-500 text-white",
    action: "アクションを完了しました",
    detail: "技術書を1章読む",
    targetGoal: "技術スキルの向上",
  },
  {
    id: 4,
    time: "18:20",
    source: "System",
    icon: Star,
    color: "bg-amber-400 text-white",
    action: "目標の達成率がアップ！",
    detail: "今日の行動が目標に大きく貢献しました",
    targetGoal: "全般",
  }
];

export function SyncJournal() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-y-auto font-sans pb-24">
      {/* Header */}
      <div className="flex items-center justify-between p-6 pt-16 bg-white/80 backdrop-blur-md sticky top-0 z-20 border-b border-stone-200">
        <button onClick={() => navigate(-1)} className="p-2 -ml-2 rounded-full hover:bg-stone-100 transition-colors">
          <ChevronLeft className="w-6 h-6 text-stone-800" />
        </button>
        <div className="font-bold text-stone-800 tracking-tight text-sm uppercase">
          アクション・ジャーナル
        </div>
        <div className="w-10"></div>
      </div>

      {/* Hero Section */}
      <div className="px-6 py-8">
        <h1 className="text-2xl font-black text-stone-900 mb-2 tracking-tight">
          今日の積み上げ
        </h1>
        <p className="text-stone-500 text-sm leading-relaxed">
          あなたの行動一つ一つが、目標という形になって確実に積み上がっています。
        </p>
      </div>

      {/* Timeline */}
      <div className="px-6 relative">
        <div className="absolute left-10 top-2 bottom-4 w-px bg-stone-200 z-0" />
        
        <div className="space-y-8 relative z-10">
          {journalEntries.map((entry) => {
            const Icon = entry.icon;
            return (
              <div key={entry.id} className="flex gap-4">
                <div className="flex flex-col items-center gap-1 mt-1">
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center shadow-sm z-10 ${entry.color}`}>
                    <Icon className="w-4 h-4" />
                  </div>
                  <span className="text-[10px] font-bold text-stone-400 mt-1">{entry.time}</span>
                </div>
                
                <div className="flex-1 bg-white rounded-2xl p-4 shadow-sm border border-stone-100">
                  <div className="flex items-center gap-2 mb-2">
                    <Target className="w-3 h-3 text-red-500" />
                    <span className="text-[10px] font-bold text-red-500 uppercase tracking-widest bg-red-50 px-2 py-0.5 rounded-full">
                      {entry.targetGoal}
                    </span>
                  </div>
                  <h3 className="font-bold text-stone-800 text-sm mb-1">{entry.action}</h3>
                  <p className="text-stone-500 text-xs">{entry.detail}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>
      
      {/* Encouragement Card */}
      <div className="px-6 mt-12 mb-8">
        <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-3xl p-6 border border-amber-100 text-center">
          <div className="w-12 h-12 bg-white rounded-full flex items-center justify-center mx-auto mb-4 shadow-sm text-amber-500">
            <Star className="w-6 h-6 fill-current" />
          </div>
          <h3 className="font-black text-amber-800 mb-2">素晴らしい1日でした</h3>
          <p className="text-amber-700/80 text-xs leading-relaxed">
            どんなに小さな一歩でも、着実に目標へ近づいています。明日も無理のないペースで進めていきましょう。
          </p>
        </div>
      </div>
    </div>
  );
}
