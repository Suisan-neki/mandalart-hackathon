import { createBrowserRouter, Navigate, Outlet, NavLink, useOutletContext } from "react-router";
import { DemoPortal } from "./components/DemoPortal";
import { RootLayout } from "./components/RootLayout";
import { Splash } from "./components/Splash";
import { Onboarding } from "./components/Onboarding";
import { Integrations } from "./components/Integrations";
import { MandalartInput } from "./components/MandalartInput";
import { Home } from "./components/Home";
import { MandalartView } from "./components/MandalartView";
import { DailyCheckin } from "./components/DailyCheckin";
import { ResultView } from "./components/ResultView";
import { Settings } from "./components/Settings";
import { BlockMandalart } from "./components/BlockMandalart";
import { GoalReview } from "./components/GoalReview";
import { ErrorDemo } from "./components/ErrorDemo";
import { SyncJournal } from "./components/SyncJournal";
import { SyncSettings } from "./components/SyncSettings";
import { ActionEditor } from "./components/ActionEditor";
import { ErrorRateLimit } from "./components/ErrorRateLimit";
import { ErrorAuth } from "./components/ErrorAuth";
import { ErrorUnknown } from "./components/ErrorUnknown";
import { ErrorOffline } from "./components/ErrorOffline";
import { TimeAllocation } from "./components/TimeAllocation";
import { WeeklyReport } from "./components/WeeklyReport";
import { Grid, CheckSquare, BarChart3, Settings as SettingsIcon } from "lucide-react";

function NavItem({ to, icon, label }: { to: string; icon: React.ReactNode; label: string }) {
  let IconElement = Grid;
  if (label === "アクション") IconElement = CheckSquare;
  if (label === "記録") IconElement = BarChart3;
  if (label === "設定") IconElement = SettingsIcon;

  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        `flex flex-col items-center justify-center w-16 h-full gap-1 pt-2 transition-colors ${
          isActive ? "text-indigo-600 font-bold" : "text-stone-400"
        }`
      }
    >
      <IconElement className="w-6 h-6 mb-1" />
      <span className="text-[10px]">{label}</span>
    </NavLink>
  );
}

function MainLayout() {
  const context = useOutletContext();
  return (
    <div className="flex flex-col h-full w-full bg-stone-50 overflow-hidden relative">
      <div className="flex-1 overflow-y-auto w-full h-full pb-20">
        <Outlet context={context} />
      </div>
      
      {/* Bottom Navigation Bar */}
      <div className="absolute bottom-0 left-0 w-full bg-white border-t border-stone-200 flex justify-around items-center h-[88px] pb-6 px-2 shadow-[0_-2px_10px_rgba(0,0,0,0.05)] z-50">
        <NavItem to="/app/block-mandalart" icon={<Grid className="w-6 h-6" />} label="目標" />
        <NavItem to="/app/home" icon={<CheckSquare className="w-6 h-6" />} label="アクション" />
        <NavItem to="/app/result" icon={<BarChart3 className="w-6 h-6" />} label="記録" />
        <NavItem to="/app/settings" icon={<SettingsIcon className="w-6 h-6" />} label="設定" />
      </div>
    </div>
  );
}

export const router = createBrowserRouter([
  {
    path: "/",
    Component: RootLayout,
    children: [
      { index: true, Component: DemoPortal },
      { path: "onboarding", Component: Onboarding },
      { path: "integrations", Component: Integrations },
      { path: "mandalart-input", Component: MandalartInput },
      { path: "checkin", Component: DailyCheckin },
      { path: "time-allocation", Component: TimeAllocation },
      { path: "weekly-report", Component: WeeklyReport },
      {
        path: "app",
        Component: MainLayout,
        children: [
          { index: true, element: <Navigate to="block-mandalart" replace /> },
          { path: "time-allocation", element: <Navigate to="/time-allocation" replace /> },
          { path: "weekly-report", element: <Navigate to="/weekly-report" replace /> },
          { path: "home", Component: Home },
          { path: "mandalart", Component: MandalartView },
          { path: "block-mandalart", Component: BlockMandalart },
          { path: "goal-review", Component: GoalReview },
          { 
            path: "error-demo",
            children: [
              { index: true, Component: ErrorDemo },
              { path: "rate-limit", Component: ErrorRateLimit },
              { path: "auth", Component: ErrorAuth },
              { path: "unknown", Component: ErrorUnknown },
              { path: "offline", Component: ErrorOffline },
            ]
          },
          { path: "result", Component: ResultView },
          { path: "settings", Component: Settings },
          { path: "sync-journal", Component: SyncJournal },
          { path: "sync-settings", Component: SyncSettings },
          { path: "action-edit", Component: ActionEditor },
        ],
      },
    ],
  },
]);
