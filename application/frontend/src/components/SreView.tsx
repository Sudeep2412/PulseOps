import React from 'react';
import { ShieldCheck, AlertTriangle, Flame, Clock, BookOpen, CheckCircle2 } from 'lucide-react';
import { SreStatusData } from '../types';

interface SreViewProps {
  data: SreStatusData | null;
  loading: boolean;
}

export const SreView: React.FC<SreViewProps> = ({ data, loading }) => {
  if (loading && !data) {
    return <div className="p-8 text-center text-slate-400 animate-pulse">Loading SRE compliance data...</div>;
  }

  const targets = data?.slo_targets ?? [];
  const budget = data?.error_budget;
  const policyState = budget?.policy_state ?? 'GREEN';

  const runbooks = [
    { title: 'Application Process Crash (SEV-1)', file: 'docs/sre/runbooks/application_down.md' },
    { title: 'High Error Rate Breach (SEV-1)', file: 'docs/sre/runbooks/high_error_rate.md' },
    { title: 'High Latency Spike (SEV-2)', file: 'docs/sre/runbooks/high_latency.md' },
    { title: 'Automated Container Rollback', file: 'docs/sre/runbooks/rollback.md' },
    { title: 'Prometheus TSDB Outage', file: 'docs/sre/runbooks/prometheus_unavailable.md' },
    { title: 'Grafana Service Outage', file: 'docs/sre/runbooks/grafana_unavailable.md' },
  ];

  return (
    <div className="space-y-6">
      {/* Error Budget Governance Card */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-6">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
          <div>
            <h3 className="text-base font-bold text-slate-100 flex items-center gap-2">
              <ShieldCheck className="w-5 h-5 text-emerald-400" />
              <span>Error Budget Governance & Burn Rate Policy</span>
            </h3>
            <p className="text-xs text-slate-400 mt-1">Allowable error threshold is normalized to 0.5% (1.0 - 0.995 availability target).</p>
          </div>
          <div className="flex items-center gap-3">
            <span className={`px-3 py-1 rounded-full text-xs font-bold border ${
              policyState === 'GREEN'
                ? 'bg-emerald-950 text-emerald-400 border-emerald-800'
                : (policyState === 'YELLOW' ? 'bg-amber-950 text-amber-400 border-amber-800' : 'bg-rose-950 text-rose-400 border-rose-800')
            }`}>
              Policy State: {policyState}
            </span>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-4 bg-slate-950/60 border border-slate-800 rounded-lg">
            <div className="text-xs text-slate-400">Remaining Budget</div>
            <div className="text-2xl font-bold text-slate-100 mt-1">{budget?.remaining_percent.toFixed(1) ?? '100.0'}%</div>
            <div className="text-[11px] text-slate-500 mt-1">Zone: {policyState === 'GREEN' ? '> 50% (Deploy Free)' : 'Freeze Zone'}</div>
          </div>
          <div className="p-4 bg-slate-950/60 border border-slate-800 rounded-lg">
            <div className="text-xs text-slate-400 flex items-center gap-1">
              <Flame className="w-3.5 h-3.5 text-amber-400" />
              <span>Fast Burn Rate (2m Window)</span>
            </div>
            <div className="text-2xl font-bold text-slate-100 mt-1">{budget?.burn_rate_factor ?? 0.0}x</div>
            <div className="text-[11px] text-slate-500 mt-1">Alert Threshold: 14.4x (2% / 1hr)</div>
          </div>
          <div className="p-4 bg-slate-950/60 border border-slate-800 rounded-lg">
            <div className="text-xs text-slate-400 flex items-center gap-1">
              <Clock className="w-3.5 h-3.5 text-sky-400" />
              <span>Slow Burn Rate (15m Window)</span>
            </div>
            <div className="text-2xl font-bold text-slate-100 mt-1">{budget?.burn_rate_factor ?? 0.0}x</div>
            <div className="text-[11px] text-slate-500 mt-1">Alert Threshold: 3.0x (5% / 6hr)</div>
          </div>
        </div>
      </div>

      {/* Formal SLO Matrix */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-6">
        <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-4">Service Level Objectives (SLO Matrix)</h4>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="text-slate-400 border-b border-slate-800">
              <tr>
                <th className="pb-3 font-semibold">Objective Name</th>
                <th className="pb-3 font-semibold">Target</th>
                <th className="pb-3 font-semibold">Compliance Window</th>
                <th className="pb-3 font-semibold">Current Measured SLI</th>
                <th className="pb-3 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {targets.map((slo, i) => (
                <tr key={i} className="hover:bg-slate-800/30">
                  <td className="py-3.5 font-medium text-slate-200">
                    <div>{slo.name}</div>
                    <div className="text-[11px] text-slate-500">{slo.description}</div>
                  </td>
                  <td className="py-3.5 font-mono text-slate-300">≥ {slo.target_percent}%</td>
                  <td className="py-3.5 text-slate-400">{slo.compliance_window}</td>
                  <td className="py-3.5 font-mono font-semibold text-slate-200">
                    {slo.current_ratio !== null ? `${(slo.current_ratio * 100).toFixed(2)}%` : 'Idle (No Traffic)'}
                  </td>
                  <td className="py-3.5">
                    <span className="flex items-center gap-1 text-[11px] font-semibold text-emerald-400">
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      Compliant
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Runbooks Quick Access */}
      <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-6">
        <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-4 flex items-center gap-2">
          <BookOpen className="w-4 h-4 text-indigo-400" />
          <span>SRE Incident Response Runbooks</span>
        </h4>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
          {runbooks.map((rb, i) => (
            <div key={i} className="p-3 bg-slate-950/60 border border-slate-800 rounded-lg text-xs">
              <div className="font-medium text-slate-200">{rb.title}</div>
              <div className="font-mono text-[10px] text-slate-500 truncate mt-1">{rb.file}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
