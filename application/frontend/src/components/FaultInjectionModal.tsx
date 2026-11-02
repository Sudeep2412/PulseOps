import React, { useState } from 'react';
import { X, Zap, AlertTriangle, Clock } from 'lucide-react';

interface FaultInjectionModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const FaultInjectionModal: React.FC<FaultInjectionModalProps> = ({ isOpen, onClose }) => {
  const [errorCode, setErrorCode] = useState(500);
  const [latencyDelay, setLatencyDelay] = useState(0.5);
  const [log, setLog] = useState<string | null>(null);

  if (!isOpen) return null;

  const triggerError = async () => {
    setLog(`Dispatching error simulation HTTP ${errorCode}...`);
    try {
      const res = await fetch(`/api/v1/simulate-error?code=${errorCode}`);
      const data = await res.json();
      setLog(`[${res.status}] ${JSON.stringify(data)}`);
    } catch (e: any) {
      setLog(`Error: ${e.message}`);
    }
  };

  const triggerLatency = async () => {
    setLog(`Injecting ${latencyDelay}s latency delay...`);
    try {
      const start = Date.now();
      const res = await fetch(`/api/v1/simulate-latency?delay=${latencyDelay}`);
      const data = await res.json();
      const dur = ((Date.now() - start) / 1000).toFixed(2);
      setLog(`[${res.status} in ${dur}s] ${JSON.stringify(data)}`);
    } catch (e: any) {
      setLog(`Error: ${e.message}`);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
      <div className="bg-slate-900 border border-slate-700 rounded-xl max-w-lg w-full p-6 shadow-2xl space-y-4">
        <div className="flex items-center justify-between border-b border-slate-800 pb-3">
          <div className="flex items-center gap-2">
            <Zap className="w-5 h-5 text-indigo-400" />
            <h3 className="text-sm font-bold text-slate-100">SRE Chaos & Fault Simulator</h3>
          </div>
          <button onClick={onClose} className="text-slate-400 hover:text-slate-200">
            <X className="w-5 h-5" />
          </button>
        </div>

        <p className="text-xs text-slate-400">
          Inject safe synthetic anomalies into the live workload to verify real-time Prometheus SLI calculations and Grafana dashboard alerts.
        </p>

        <div className="space-y-4 pt-2">
          {/* Error Injection Option */}
          <div className="p-3 bg-slate-950 rounded-lg border border-slate-800 flex items-center justify-between gap-3">
            <div>
              <div className="text-xs font-semibold text-slate-200">HTTP Error Injection</div>
              <div className="text-[11px] text-slate-400">Trigger status: {errorCode}</div>
            </div>
            <div className="flex items-center gap-2">
              <select
                value={errorCode}
                onChange={(e) => setErrorCode(Number(e.target.value))}
                className="bg-slate-900 border border-slate-700 text-xs rounded px-2 py-1 text-slate-200"
              >
                <option value={500}>500 Error</option>
                <option value={502}>502 Gateway</option>
                <option value={503}>503 Unavailable</option>
              </select>
              <button
                onClick={triggerError}
                className="px-3 py-1 bg-amber-600 hover:bg-amber-500 text-white rounded text-xs font-medium"
              >
                Inject
              </button>
            </div>
          </div>

          {/* Latency Injection Option */}
          <div className="p-3 bg-slate-950 rounded-lg border border-slate-800 flex items-center justify-between gap-3">
            <div>
              <div className="text-xs font-semibold text-slate-200">Latency Delay Injection</div>
              <div className="text-[11px] text-slate-400">Delay: {latencyDelay}s</div>
            </div>
            <div className="flex items-center gap-2">
              <input
                type="range"
                min="0.1"
                max="2.0"
                step="0.1"
                value={latencyDelay}
                onChange={(e) => setLatencyDelay(Number(e.target.value))}
                className="w-20 accent-sky-400"
              />
              <button
                onClick={triggerLatency}
                className="px-3 py-1 bg-indigo-600 hover:bg-indigo-500 text-white rounded text-xs font-medium"
              >
                Inject
              </button>
            </div>
          </div>
        </div>

        {log && (
          <div className="p-3 bg-slate-950 rounded-lg border border-slate-800 text-[11px] font-mono text-slate-300">
            {log}
          </div>
        )}

        <div className="pt-2 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-xs text-slate-200 rounded-lg"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
};
