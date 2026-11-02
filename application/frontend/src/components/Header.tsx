import React, { useState, useEffect } from 'react';
import { Activity, ShieldCheck, AlertTriangle, Zap } from 'lucide-react';
import { OverviewData } from '../types';

interface HeaderProps {
  overview: OverviewData | null;
  onOpenFaultModal: () => void;
}

export const Header: React.FC<HeaderProps> = ({ overview, onOpenFaultModal }) => {
  const [timeStr, setTimeStr] = useState<string>('');

  useEffect(() => {
    const update = () => setTimeStr(new Date().toUTCString());
    update();
    const interval = setInterval(update, 1000);
    return () => clearInterval(interval);
  }, []);

  const isHealthy = overview?.platform_status === 'operational';

  return (
    <header className="bg-slate-900/90 border-b border-slate-800 backdrop-blur sticky top-0 z-40 px-6 py-4">
      <div className="max-w-7xl mx-auto flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-sky-500 to-indigo-600 flex items-center justify-center shadow-lg shadow-sky-500/20">
            <Activity className="w-6 h-6 text-white animate-pulse" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-xl font-bold bg-gradient-to-r from-sky-400 to-indigo-300 bg-clip-text text-transparent">
                PulseOps
              </h1>
              <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-slate-800 text-slate-300 border border-slate-700">
                v1.0.0
              </span>
            </div>
            <p className="text-xs text-slate-400">Enterprise CI/CD & SRE Observability Platform (AWS)</p>
          </div>
        </div>

        <div className="flex items-center flex-wrap gap-3">
          {/* Status Indicator */}
          <div className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold border ${
            isHealthy 
              ? 'bg-emerald-950/60 text-emerald-400 border-emerald-800/80'
              : 'bg-amber-950/60 text-amber-400 border-amber-800/80'
          }`}>
            <span className={`w-2 h-2 rounded-full ${isHealthy ? 'bg-emerald-400 animate-ping' : 'bg-amber-400'}`} />
            <span>{isHealthy ? 'All Systems Operational' : 'Platform Degraded'}</span>
          </div>

          {/* Environment */}
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-slate-800/80 text-slate-300 border border-slate-700 text-xs">
            <ShieldCheck className="w-3.5 h-3.5 text-sky-400" />
            <span>AWS EC2 • us-east-1</span>
          </div>

          {/* Clock */}
          <div className="text-xs font-mono text-slate-400 px-3 py-1.5 rounded-full bg-slate-900 border border-slate-800 hidden sm:block">
            {timeStr}
          </div>

          {/* Fault Simulation CTA */}
          <button
            onClick={onOpenFaultModal}
            className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-medium transition shadow-md shadow-indigo-600/30"
          >
            <Zap className="w-3.5 h-3.5" />
            <span>Fault Simulator</span>
          </button>
        </div>
      </div>
    </header>
  );
};
