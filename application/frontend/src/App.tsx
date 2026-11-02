import React, { useState, useEffect } from 'react';
import { Header } from './components/Header';
import { Navigation } from './components/Navigation';
import { OverviewView } from './components/OverviewView';
import { ApplicationView } from './components/ApplicationView';
import { InfrastructureView } from './components/InfrastructureView';
import { SreView } from './components/SreView';
import { DeploymentsView } from './components/DeploymentsView';
import { FaultInjectionModal } from './components/FaultInjectionModal';
import { ActiveTab, OverviewData, SreStatusData, InfrastructureData, DeploymentsData } from './types';

export const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<ActiveTab>('overview');
  const [overview, setOverview] = useState<OverviewData | null>(null);
  const [sreData, setSreData] = useState<SreStatusData | null>(null);
  const [infraData, setInfraData] = useState<InfrastructureData | null>(null);
  const [deploymentsData, setDeploymentsData] = useState<DeploymentsData | null>(null);
  const [loading, setLoading] = useState<boolean>(true);
  const [faultModalOpen, setFaultModalOpen] = useState<boolean>(false);

  const fetchAllData = async () => {
    try {
      const [ovRes, sreRes, infRes, depRes] = await Promise.all([
        fetch('/api/v1/overview'),
        fetch('/api/v1/sre/status'),
        fetch('/api/v1/infrastructure'),
        fetch('/api/v1/deployments')
      ]);
      if (ovRes.ok) setOverview(await ovRes.json());
      if (sreRes.ok) setSreData(await sreRes.json());
      if (infRes.ok) setInfraData(await infRes.json());
      if (depRes.ok) setDeploymentsData(await depRes.json());
    } catch (e) {
      console.error('Error fetching live telemetry', e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAllData();
    const interval = setInterval(fetchAllData, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="min-h-screen bg-[#0b1120] text-slate-100 flex flex-col">
      <Header overview={overview} onOpenFaultModal={() => setFaultModalOpen(true)} />
      <Navigation activeTab={activeTab} onTabChange={setActiveTab} />

      <main className="flex-1 max-w-7xl w-full mx-auto p-6">
        {activeTab === 'overview' && (
          <OverviewView overview={overview} loading={loading} onNavigateTab={setActiveTab} />
        )}
        {activeTab === 'application' && <ApplicationView />}
        {activeTab === 'infrastructure' && (
          <InfrastructureView data={infraData} loading={loading} />
        )}
        {activeTab === 'sre' && <SreView data={sreData} loading={loading} />}
        {activeTab === 'deployments' && (
          <DeploymentsView data={deploymentsData} loading={loading} />
        )}
      </main>

      <FaultInjectionModal
        isOpen={faultModalOpen}
        onClose={() => setFaultModalOpen(false)}
      />

      <footer className="border-t border-slate-800/80 bg-slate-900/40 py-4 px-6 text-center text-xs text-slate-500">
        PulseOps Enterprise Observability & SRE Workload • AWS EC2 & Docker Compose Architecture
      </footer>
    </div>
  );
};

export default App;
