# PulseOps Alertmanager Routing & Notification Architecture

## 1. Routing Tree (`monitoring/alertmanager/alertmanager.yml`)
Alerts from Prometheus are classified by severity (`critical`, `warning`, `info`):

```yaml
route:
  group_by: ['alertname', 'severity', 'service']
  group_wait: 10s
  group_interval: 1m
  repeat_interval: 4h
  receiver: 'sre-oncall-default'
  routes:
    - match:
        severity: critical
      receiver: 'sre-pager-critical'
      continue: true
    - match:
        severity: warning
      receiver: 'sre-slack-warning'
```

## 2. Alert Severities
- **Critical (SEV-1)**: Fast burn rate breach ($14.4	imes$ in 2m), application core container down, host disk $> 90\%$.
- **Warning (SEV-2)**: Slow burn rate breach ($3.0	imes$ in 15m), P95 latency SLO breach, container restart loops.
- **Info (SEV-3)**: Informational deployment events and scheduled maintenance notifications.
