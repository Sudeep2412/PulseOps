import React from 'react';
import { LayoutDashboard, Activity, Server, ShieldAlert, GitBranch } from 'lucide-react';
import { ActiveTab } from '../types';

interface NavigationProps {
  activeTab: ActiveTab;
  onTabChange: (tab: ActiveTab) => void;
}

export const Navigation: React.FC<NavigationProps> = ({ activeTab, onTabChange }) => {
  const tabs = [
    { id: 'overview', label: 'Platform Overview', icon: LayoutDashboard },
    { id: 'application', label: 'Application Workload', icon: Activity },
    { id: 'infrastructure', label: 'Fleet & Infrastructure', icon: Server },
    { id: 'sre', label: 'SLOs & Reliability', icon: ShieldAlert },
    { id: 'deployments', label: 'CI/CD Deployments', icon: GitBranch },
  ];

  return (
    <nav className="bg-slate-900/60 border-b border-slate-800 px-6 overflow-x-auto">
      <div className="max-w-7xl mx-auto flex gap-2 py-2">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id as ActiveTab)}
              className={`flex items-center gap-2 px-4 py-2.5 rounded-lg text-xs font-medium whitespace-nowrap transition-all ${
                isActive
                  ? 'bg-sky-500/10 text-sky-400 border border-sky-500/30 shadow-sm'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/50'
              }`}
            >
              <Icon className={`w-4 h-4 ${isActive ? 'text-sky-400' : 'text-slate-400'}`} />
              <span>{tab.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
