import React, { useState } from 'react';
import { Activity, Play, AlertCircle, CheckCircle, Clock } from 'lucide-react';

export const ApplicationView: React.FC = () => {
  const [workloadItems, setWorkloadItems] = useState<number>(5);
  const [workloadResult, setWorkloadResult] = useState<any>(null);
  const [loadingWorkload, setLoadingWorkload] = useState<boolean>(false);

  const [errorCode, setErrorCode] = useState<number>(500);
  const [errorResult, setErrorResult] = useState<any>(null);
  
  const [latencyDelay, setLatencyDelay] = useState<number>(0.2);
  const [latencyResult, setLatencyResult] = useState<any>(null);
  const [loadingLatency, setLoadingLatency] = useState<boolean>(false);

  const runWorkload = async () => {
    setLoadingWorkload(true);
    try {
      const res = await fetch(`/api/v1/workload?items=${workloadItems}`);
      const data = await res.json();
      setWorkloadResult(data);
    } catch (e: any) {
      setWorkloadResult({ error: e.message });
    } finally {
      setLoadingWorkload(false);
    }
  };

  const triggerError = async () => {
    try {
      const res = await fetch(`/api/v1/simulate-error?code=${errorCode}`);
      const data = await res.json();
      setErrorResult({ status: res.status, data });
    } catch (e: any) {
      setErrorResult({ error: e.message });
    }
  };

  const triggerLatency = async () => {
    setLoadingLatency(true);
    const start = performance.now();
    try {
      const res = await fetch(`/api/v1/simulate-latency?delay=${latencyDelay}`);
      const data = await res.json();
      const clientDuration = ((performance.now() - start) / 1000).toFixed(3);
      setLatencyResult({ clientDuration, data });
    } catch (e: any) {
      setLatencyResult({ error: e.message });
    } finally {
      setLoadingLatency(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="p-4 rounded-xl bg-slate-900 border border-slate-800">
        <h3 className="text-sm font-semibold text-slate-100 flex items-center gap-2">
          <Activity className="w-4 h-4 text-sky-400" />
          <span>Core Microservice Telemetry & Workload Controller</span>
        </h3>
        <p className="text-xs text-slate-400 mt-1">
          Executes realistic business transactions, logs structured JSON events, and emits SRE metrics (throughput, error rate, latency histogram) scraped by Prometheus every 15s.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Workload Generator */}
        <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
          <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3">Transaction Workload</h4>
          <p className="text-xs text-slate-400 mb-4">Simulates microservice transaction batch processing and records Golden Signal metrics.</p>
          
          <div className="space-y-3">
            <div>
              <label className="text-xs text-slate-300 block mb-1">Batch Items Count (1-100):</label>
              <input
                type="number"
                min="1"
                max="100"
                value={workloadItems}
                onChange={(e) => setWorkloadItems(Number(e.target.value))}
                className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-1.5 text-xs font-mono text-slate-100 focus:outline-none focus:border-sky-500"
              />
            </div>
            <button
              onClick={runWorkload}
              disabled={loadingWorkload}
              className="w-full flex items-center justify-center gap-2 py-2 bg-sky-600 hover:bg-sky-500 text-white rounded-lg text-xs font-medium transition disabled:opacity-50"
            >
              <Play className="w-3.5 h-3.5" />
              <span>{loadingWorkload ? 'Processing...' : 'Execute Workload Request'}</span>
            </button>
          </div>

          {workloadResult && (
            <div className="mt-4 p-3 bg-slate-950 rounded-lg border border-slate-800 text-[11px] font-mono text-emerald-400 overflow-x-auto max-h-40">
              <pre>{JSON.stringify(workloadResult, null, 2)}</pre>
            </div>
          )}
        </div>

        {/* Error Injection */}
        <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
          <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3">Fault Injection (Error Rate)</h4>
          <p className="text-xs text-slate-400 mb-4">Injects HTTP exceptions to observe Prometheus Error Rate SLI degradation and burn-rate alert triggers.</p>

          <div className="space-y-3">
            <div>
              <label className="text-xs text-slate-300 block mb-1">Select Status Code:</label>
              <select
                value={errorCode}
                onChange={(e) => setErrorCode(Number(e.target.value))}
                className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-1.5 text-xs text-slate-100 focus:outline-none focus:border-amber-500"
              >
                <option value={500}>500 Internal Server Error (Outage)</option>
                <option value={502}>502 Bad Gateway (Upstream Outage)</option>
                <option value={503}>503 Service Unavailable (Degraded)</option>
                <option value={400}>400 Bad Request (Client Error)</option>
                <option value={404}>404 Not Found (Missing Route)</option>
              </select>
            </div>
            <button
              onClick={triggerError}
              className="w-full flex items-center justify-center gap-2 py-2 bg-amber-600 hover:bg-amber-500 text-white rounded-lg text-xs font-medium transition"
            >
              <AlertCircle className="w-3.5 h-3.5" />
              <span>Simulate HTTP {errorCode} Fault</span>
            </button>
          </div>

          {errorResult && (
            <div className="mt-4 p-3 bg-slate-950 rounded-lg border border-slate-800 text-[11px] font-mono text-amber-400 overflow-x-auto max-h-40">
              <pre>{JSON.stringify(errorResult, null, 2)}</pre>
            </div>
          )}
        </div>

        {/* Latency Injection */}
        <div className="bg-slate-900/80 border border-slate-800 rounded-xl p-5">
          <h4 className="text-xs font-semibold uppercase tracking-wider text-slate-400 mb-3">Fault Injection (Latency)</h4>
          <p className="text-xs text-slate-400 mb-4">Injects request duration delays to test histogram buckets (&lt;500ms, &lt;1s) and P95 latency alerts.</p>

          <div className="space-y-3">
            <div>
              <div className="flex justify-between text-xs text-slate-300 mb-1">
                <span>Injected Delay:</span>
                <span className="font-mono text-sky-400">{latencyDelay.toFixed(2)}s</span>
              </div>
              <input
                type="range"
                min="0.1"
                max="2.5"
                step="0.1"
                value={latencyDelay}
                onChange={(e) => setLatencyDelay(Number(e.target.value))}
                className="w-full accent-sky-400 cursor-pointer"
              />
            </div>
            <button
              onClick={triggerLatency}
              disabled={loadingLatency}
              className="w-full flex items-center justify-center gap-2 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg text-xs font-medium transition disabled:opacity-50"
            >
              <Clock className="w-3.5 h-3.5" />
              <span>{loadingLatency ? `Waiting ${latencyDelay}s...` : 'Simulate Latency Spike'}</span>
            </button>
          </div>

          {latencyResult && (
            <div className="mt-4 p-3 bg-slate-950 rounded-lg border border-slate-800 text-[11px] font-mono text-indigo-400 overflow-x-auto max-h-40">
              <pre>{JSON.stringify(latencyResult, null, 2)}</pre>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
