# PulseOps Error Budget Policy

## 1. Overview

An Error Budget represents the acceptable amount of unreliability a service can experience without violating its Service Level Objectives (SLOs).

For the PulseOps Availability SLO of **99.5%**:
$$\text{Error Budget} = 1.0 - 0.995 = 0.5\% \text{ (0.005 allowable error ratio)}$$

---

## 2. Burn Rate Definitions

Burn rate measures how quickly the error budget is consumed relative to the allowable rate:
- **Burn Rate 1.0x**: The error budget will be exactly exhausted at the end of the 30-day window.
- **Burn Rate 14.4x**: 2% of the budget is consumed in 1 hour; 100% is exhausted in 2 days. (Triggers Critical Alert).
- **Burn Rate 3.0x**: 5% of the budget is consumed in 6 hours. (Triggers Warning Alert).

---

## 3. Operational Policy Matrix

| Remaining Budget | Burn Rate | Operational State | Allowed Actions | Restricted Actions |
| :--- | :--- | :--- | :--- | :--- |
| **> 50%** | $< 3.0$x | **Green (Normal)** | Standard CI/CD, feature releases, controlled experiments | None |
| **20% – 50%** | $\ge 3.0$x | **Yellow (Elevated)** | Urgent bug fixes, routine deployments with monitoring | High-risk architectural changes |
| **< 20%** | $\ge 14.4$x | **Red (Critical)** | Reliability fixes, incident remediation, rollbacks only | Feature releases halted until recovery |

---

## 4. Recording Rules & Metrics

- `pulseops:error_budget_remaining:percent_5m`: Remaining budget percentage ($0$–$100\%$).
- `pulseops:error_budget_consumed:percent_5m`: Consumed budget percentage.
- `pulseops:error_budget_burn_rate:5m`: Current instantaneous burn rate multiple.
- `pulseops:error_budget_burn_rate:1h`: Sustained hourly burn rate multiple.
