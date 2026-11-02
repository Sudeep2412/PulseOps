# PulseOps Service Level Indicators (SLIs) & Service Level Objectives (SLOs)

## 1. Executive Summary

This document specifies the Service Level Objectives (SLOs) and underlying Service Level Indicators (SLIs) established for PulseOps workloads running on AWS EC2.

---

## 2. SLI Specifications

### 2.1 Availability SLI
- **Definition**: The proportion of valid HTTP requests successfully handled by the application (returning HTTP status codes `200`–`399`).
- **Eligible Traffic**: All HTTP requests received by the PulseOps core backend engine. For user-facing availability, internal synthetic probes (`health.health`, `health.ready`, and `metrics.metrics`) are tracked both holistically and separately.
- **Metric Formula**:
  $$\text{Availability SLI} = \frac{\sum \text{rate}(\text{pulseops\_http\_requests\_total}[\text{status} \in [200, 399]])}{\sum \text{rate}(\text{pulseops\_http\_requests\_total})}$$
- **Recording Rule**: `pulseops:sli_availability:ratio_rate5m`

### 2.2 Latency SLI
- **Definition**: The percentage of eligible requests completing within acceptable latency thresholds.
- **Thresholds**:
  - **Standard Target**: 95% of requests completed in $\le 500$ ms.
  - **Degraded Target**: 99% of requests completed in $\le 1.0$ s.
- **Metric Formula**:
  $$\text{Latency SLI}_{500\text{ms}} = \frac{\sum \text{rate}(\text{pulseops\_http\_request\_duration\_seconds\_bucket}[le=0.5])}{\sum \text{rate}(\text{pulseops\_http\_request\_duration\_seconds\_count})}$$
- **Recording Rule**: `pulseops:sli_latency_under_500ms:ratio_rate5m`

### 2.3 Error Rate SLI
- **Definition**: The ratio of server errors (HTTP `5xx`) relative to total traffic.
- **Recording Rule**: `pulseops:sli_error_rate:ratio_rate5m`

### 2.4 Deployment Reliability SLI
- **Definition**: The proportion of continuous deployments completing verification and health checks without triggering rollback.
- **Target**: 95% over a 30-day rolling window.

### 2.5 Recovery SLI (MTTR)
- **Definition**: Time elapsed between simulated failure detection and complete service restoration.
- **Engineering Baseline**: MTTR $\le 60$ seconds for automated container recovery.

---

## 3. SLO Targets

| Objective | Target | Compliance Window | Evaluation Expression |
| :--- | :--- | :--- | :--- |
| **Availability** | $\ge 99.5\%$ | Rolling 30 days | `pulseops:sli_availability:ratio_rate5m >= 0.995` |
| **P95 Latency** | $\ge 95\%$ under $500$ ms | Rolling 30 days | `pulseops:sli_latency_under_500ms:ratio_rate5m >= 0.95` |
| **P99 Latency** | $\ge 99\%$ under $1.0$ s | Rolling 30 days | `pulseops:sli_latency_under_1s:ratio_rate5m >= 0.99` |
| **Deployment Success** | $\ge 95\%$ success | Rolling 30 days | Deployment without rollback |

---

## 4. Edge Cases & Safeguards

- **Zero-Traffic Conditions**: During maintenance windows or periods of idle traffic, the SLI calculation is protected with fallback vector guards (`or vector(1)`) to avoid division-by-zero or reporting false outages.
- **Probe Disambiguation**: Health checks (`/health`, `/ready`) are tagged under `endpoint="health.*"` and evaluated independently from workload traffic.
