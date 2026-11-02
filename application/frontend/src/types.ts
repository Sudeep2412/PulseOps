export type ActiveTab = 'overview' | 'application' | 'infrastructure' | 'sre' | 'deployments';

export interface OverviewData {
  service: string;
  platform_status: string;
  environment: string;
  version: string;
  timestamp: string;
  slis: {
    availability?: number | null;
    availability_ratio?: number | null;
    availability_percent: number | null;
    measured_p95_latency_ms: number | null;
    latency_slo_compliance_ratio: number | null;
    latency_p95?: number | null;
    error_rate_percent: number;
    traffic_rps: number;
    error_budget_remaining_percent: number;
    burn_rate: number;
  };
  deployments: {
    total_successful: number;
    last_deployment: {
      timestamp: string;
      commit_sha: string;
      status: string;
      duration_seconds: number;
    } | null;
  };
  incidents: {
    mttr_seconds: number;
  };
}

export interface SloTarget {
  name: string;
  target_percent: number;
  threshold_seconds?: number;
  compliance_window: string;
  current_ratio: number | null;
  compliant: boolean;
  description: string;
}

export interface SreStatusData {
  slo_targets: SloTarget[];
  error_budget: {
    allowable_error_rate_percent: number;
    remaining_percent: number;
    policy_state: 'GREEN' | 'YELLOW' | 'RED';
    burn_rate_factor: number;
    fast_burn_alert_threshold: number;
    slow_burn_alert_threshold: number;
  };
  incident_metrics: {
    mttr_seconds: number;
    evaluated_incidents_count: number;
    history: Array<{
      incident_id: string;
      timestamp: string;
      title: string;
      severity: string;
      duration_seconds: number;
    }>;
  };
}

export interface InfrastructureData {
  host: {
    os: string;
    cpu_cores: number;
    architecture: string;
    node_name: string;
    loopback_enforced: boolean;
  };
  containers: Array<{
    name: string;
    role: string;
    port: number;
    status: string;
    healthy: boolean;
    binding: string;
  }>;
  telemetry: {
    targets_healthy: number;
    targets_total: number;
    container_memory_bytes: number;
  };
}

export interface DeploymentEvent {
  timestamp: string;
  commit_sha: string;
  status: string;
  duration_seconds: number;
}

export interface DeploymentsData {
  current_commit_sha: string;
  ecr_registry: string;
  repository: string;
  rollback_baseline_tag: string;
  rollback_baseline_available: boolean;
  deployment_history: DeploymentEvent[];
  total_recorded?: number;
  status?: string;
}
