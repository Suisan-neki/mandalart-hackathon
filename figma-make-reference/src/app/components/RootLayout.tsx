import { Outlet } from "react-router";
import { useState, useEffect } from "react";
import { OfflineBanner, SyncOverlay } from "./Resilience";
import { Wifi, BatteryMedium, Signal } from "lucide-react";

function StatusBar() {
  const [time, setTime] = useState("9:41");

  useEffect(() => {
    // Just keep it static for the typical iOS mockup look, 
    // or we could use real time if preferred. 9:41 is standard.
  }, []);

  return (
    <div className="absolute top-0 left-0 right-0 h-14 z-[100] flex justify-between items-center px-6 pointer-events-none mix-blend-difference text-white/90">
      <div className="text-[15px] font-semibold tracking-tight w-[54px] text-center">
        {time}
      </div>
      <div className="flex gap-2 items-center">
        <Signal className="w-4 h-4" />
        <Wifi className="w-4 h-4" />
        <BatteryMedium className="w-6 h-6 -mr-1" />
      </div>
    </div>
  );
}

export function RootLayout() {
  const [isOffline, setIsOffline] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);
  
  // Simulate online/offline
  useEffect(() => {
    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);
    
    window.addEventListener("online", handleOnline);
    window.addEventListener("offline", handleOffline);
    
    return () => {
      window.removeEventListener("online", handleOnline);
      window.removeEventListener("offline", handleOffline);
    };
  }, []);

  return (
    <div className="flex h-screen w-full flex-col bg-stone-900 justify-center items-center relative">
      <div className="w-full h-full sm:max-w-md sm:h-[844px] bg-white sm:rounded-[40px] shadow-2xl overflow-hidden relative sm:border-8 sm:border-stone-800">
        <StatusBar />
        <OfflineBanner isOffline={isOffline} />
        <SyncOverlay isSyncing={isSyncing} />
        <Outlet context={{ setIsSyncing }} />
      </div>
    </div>
  );
}
