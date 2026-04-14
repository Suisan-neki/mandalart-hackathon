import { useEffect } from "react";
import { useNavigate } from "react-router";
import { motion } from "motion/react";
import { Activity } from "lucide-react";

export function Splash() {
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate("/onboarding");
    }, 3000);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="flex h-full w-full flex-col items-center justify-center bg-stone-50 text-stone-900 font-sans relative overflow-hidden">
      {/* Soft background glow */}
      <motion.div
        animate={{ 
          scale: [1, 1.2, 1],
          opacity: [0.3, 0.5, 0.3]
        }}
        transition={{ 
          duration: 4, 
          repeat: Infinity,
          ease: "easeInOut" 
        }}
        className="absolute w-96 h-96 bg-amber-200/40 blur-[100px] rounded-full"
      />

      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.8, ease: "easeOut" }}
        className="flex flex-col items-center z-10"
      >
        <div className="relative mb-6">
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            className="absolute -inset-4 border border-amber-300/30 rounded-full"
          />
          <motion.div
            animate={{ rotate: -360 }}
            transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
            className="absolute -inset-8 border border-amber-200/20 rounded-full"
          />
          <div className="w-20 h-20 bg-gradient-to-br from-amber-100 to-amber-300 rounded-2xl flex items-center justify-center shadow-lg shadow-amber-500/20 rotate-12">
            <Activity className="w-10 h-10 text-amber-700 -rotate-12" />
          </div>
        </div>
        
        <h1 className="text-3xl font-bold tracking-tight text-stone-800 mb-3">
          Mandalart <span className="text-amber-600 font-black">Sync</span>
        </h1>
        <p className="text-stone-500 text-sm font-medium tracking-wide">
          掲げた目標と現実を、優しく同期する。
        </p>
      </motion.div>
    </div>
  );
}
