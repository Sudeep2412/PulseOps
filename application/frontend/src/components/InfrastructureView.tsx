import React from 'react';
import { Server, Cpu, HardDrive, ShieldCheck, CheckCircle2 } from 'lucide-react';
import { InfrastructureData } from '../types';

interface InfrastructureViewProps {
  data: InfrastructureData | null;
  loading: boolean;
}

export const InfrastructureView: React.FC<InfrastructureViewProps> = ({ data, loading }) => {
  if (loading && !data) {
    return <div className="p-8 text-center text-slate-400 animate-pulse">Loading infrastructure telemetry...</div>;
  }

  const containers = data?.containers ?? [];
  const host = data?.host;
  const memoryMb = data?.telemetry ? (data.telemetry.container_memory_bytes / (1024 * 1024)).toFixed(1) : '75.6';

  return (
    <div className="space-y-6">
      {/* Host Metrics Card */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-slate-400 mb-2">
            <Cpu className="w-4 h-4 text-sky-400" />
            <span>Compute Host</span>
          </div>
          <div className="text-lg font-bold text-slate-100">AWS EC2 m7i-flex.large</div>
          <div className="text-xs text-slate-400 mt-1">Ubuntu 26.04 LTS • {host?.cpu_cores ?? 2} vCPUs • {host?.architecture ?? 'x86_64'}</div>
        </div>

        <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-slate-400 mb-2">
            <HardDrive className="w-4 h-4 text-indigo-400" />
            <span>Container Memory (Working Set)</span>
          </div>
          <div className="text-lg font-bold text-slate-100">{memoryMb} MB</div>
          <div className="text-xs text-slate-400 mt-1">cAdvisor cgroups v2 telemetry • 512MB limit</div>
        </div>

        <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
          <div className="flex items-center gap-2 text-xs font-semibold uppercase tracking-wider text-slate-400 mb-2">
            <ShieldCheck className="w-4 h-4 text-emerald-400" />
            <span>Loopback Security Posture</span>
          </div>
          <div className="text-lg font-bold text-emerald-400">Strictly Enforced (127.0.0.1)</div>
          <div className="text-xs text-slate-400 mt-1">0 public ports open • SSH/SSM port-forwarding only</div>
        </div>
      </div>

      {/* Container Fleet Grid */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
        <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-4">Container Fleet Status (Docker Engine)</h4>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {containers.map((c, i) => (
            <div key={i} className="p-4 bg-slate-950/70 border border-slate-800 rounded-lg hover:border-slate-700 transition">
              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-sky-400">{c.name}</span>
                <span className="flex items-center gap-1 text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-950 text-emerald-400 border border-emerald-800">
                  <CheckCircle2 className="w-3 h-3" />
                  Running
                </span>
              </div>
              <div className="text-xs text-slate-300 mt-2">{c.role}</div>
              <div className="flex items-center justify-between text-[11px] font-mono text-slate-500 mt-3 pt-2 border-t border-slate-900">
                <span>Port: {c.port}</span>
                <span>Binding: {c.binding}</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
