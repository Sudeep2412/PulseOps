#!/usr/bin/env bash
# ==============================================================================
# PulseOps - Production SRE & Observability Automated Validation Engine
# ==============================================================================
set -euo pipefail

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

log_pass() {
    echo "  [PASS] $1"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

log_fail() {
    echo "  [FAIL] $1: $2" >&2
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

echo "========================================================================"
echo "PulseOps SRE Automated Platform Validation"
echo "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Host:      $(hostname)"
echo "========================================================================"

# 1. Application Container Health
echo "1. Checking Core Application Health..."
if curl -s -f http://127.0.0.1:8000/health | grep -q '"status"[[:space:]]*:[[:space:]]*"healthy"'; then
    log_pass "Core Application /health returned healthy"
else
    log_fail "Core Application /health" "Health endpoint unreachable or unhealthy"
fi

if curl -s -f http://127.0.0.1:8000/ready | grep -q '"status"[[:space:]]*:[[:space:]]*"ready"'; then
    log_pass "Core Application /ready returned ready"
else
    log_fail "Core Application /ready" "Readiness probe failed"
fi

# 2. Monitoring Containers Health
echo "2. Checking Monitoring Containers State..."
MONITORING_CONTAINERS=("pulseops-prometheus" "pulseops-grafana" "pulseops-alertmanager" "pulseops-node-exporter" "pulseops-cadvisor")
for c in "${MONITORING_CONTAINERS[@]}"; do
    STATE=$(docker inspect -f '{{.State.Running}}' "$c" 2>/dev/null || echo "false")
    if [ "$STATE" = "true" ]; then
        log_pass "Container '$c' is running"
    else
        log_fail "Container '$c'" "Container is not in running state"
    fi
done

# 3. Prometheus Scrape Targets
echo "3. Checking Prometheus Scrape Target Health..."
TARGETS_UP=$(curl -s http://127.0.0.1:9090/api/v1/targets | grep -o '"health":"up"' | wc -l)
if [ "$TARGETS_UP" -ge 5 ]; then
    log_pass "All 5 active Prometheus targets are healthy ('up')"
else
    log_fail "Prometheus Targets" "Only $TARGETS_UP/5 targets reporting 'up'"
fi

# 4. Prometheus Rules Loading & Evaluation
echo "4. Checking SRE Rule Groups Loading..."
RULE_GROUPS=$(curl -s http://127.0.0.1:9090/api/v1/rules | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin)
    groups = data.get("data", {}).get("groups", [])
    print(len(groups))
except Exception:
    print(0)
')
if [ "$RULE_GROUPS" -ge 4 ]; then
    log_pass "All 4 SRE rule groups successfully loaded ($RULE_GROUPS groups found)"
else
    log_fail "SRE Rule Groups" "Expected at least 4 rule groups, found $RULE_GROUPS"
fi

# 5. Alertmanager Health
echo "5. Checking Alertmanager Cluster State..."
if curl -s -f http://127.0.0.1:9093/api/v2/status | grep -q '"status":"ready"'; then
    log_pass "Alertmanager cluster state is 'ready'"
else
    log_fail "Alertmanager" "Status API did not report 'ready'"
fi

# 6. Grafana Health & Dashboards
echo "6. Checking Grafana Service & Provisioned Dashboards..."
if curl -s -f http://127.0.0.1:3000/api/health | grep -q '"database"[[:space:]]*:[[:space:]]*"ok"'; then
    log_pass "Grafana service and SQLite storage database is 'ok'"
else
    log_fail "Grafana Health" "Grafana /api/health probe failed"
fi

ENV_FILE="/home/ubuntu/PulseOps/monitoring/.env.monitoring"
if [ -f "$ENV_FILE" ]; then
    GF_PASS=$(grep '^GRAFANA_ADMIN_PASSWORD=' "$ENV_FILE" | cut -d '=' -f2-)
    AUTH_HEADER="Basic $(echo -n "admin:${GF_PASS}" | base64)"
    DASHBOARD_COUNT=$(curl -s -H "Authorization: ${AUTH_HEADER}" "http://127.0.0.1:3000/api/search?type=dash-db" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    print(len(d))
except Exception:
    print(0)
')
    if [ "$DASHBOARD_COUNT" -ge 4 ]; then
        log_pass "Grafana pre-provisioned dashboards loaded ($DASHBOARD_COUNT dashboards found)"
    else
        log_fail "Grafana Dashboards" "Expected at least 4 dashboards, found $DASHBOARD_COUNT"
    fi
else
    log_fail "Grafana Auth" ".env.monitoring not found on host"
fi

# 7. SLI / SLO Recording Rules Query Validity
echo "7. Checking SLI / SLO Recording Rules Evaluation..."
# Warm up 5m traffic window for SLI calculation
for i in 1 2 3 4 5; do
    curl -s http://127.0.0.1:8000/api/v1/workload >/dev/null 2>&1 || true
done
sleep 2
check_promql() {
    local query="$1"
    local desc="$2"
    local res
    res=$(curl -s -G --data-urlencode "query=${query}" http://127.0.0.1:9090/api/v1/query | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    r = d.get("data", {}).get("result", [])
    print(len(r))
except Exception:
    print(0)
')
    if [ "$res" -ge 1 ]; then
        log_pass "$desc returned active series"
    else
        log_fail "$desc" "Query '${query}' returned no series"
    fi
}

check_promql "pulseops:sli_availability:ratio_rate5m" "Availability SLI"
check_promql "pulseops:sli_latency_under_500ms:ratio_rate5m" "Latency SLI (<500ms)"
check_promql "pulseops:error_budget_remaining:percent_5m" "Error Budget Remaining (%)"
check_promql "pulseops:error_budget_burn_rate:5m" "Error Budget Burn Rate"
check_promql "pulseops_deployment_events_total" "Durable Deployment Event Metrics"
check_promql "pulseops_incident_recovery_mttr_seconds" "Durable Incident MTTR Metrics"

# 8. Container Telemetry
echo "8. Checking Container Infrastructure Metrics (cAdvisor)..."
check_promql 'container_cpu_usage_seconds_total{image=~".*pulseops.*"}' "Container CPU Telemetry"
check_promql 'container_memory_working_set_bytes{image=~".*pulseops.*"}' "Container Memory Telemetry"

# 9. Loopback Security
echo "9. Checking Loopback Security Posture..."
# Column 5 in ss -tulpn is the local address (e.g. 127.0.0.1:3000 or 0.0.0.0:22)
OPEN_MONITORING=$(ss -tulpn | awk '{print $5}' | grep -c -E '^0\.0\.0\.0:(3000|8000|8080|9090|9093|9100)$' || true)
if [ "$OPEN_MONITORING" -eq 0 ]; then
    log_pass "All application and monitoring ports are strictly bound to 127.0.0.1 (0 public exposures)"
else
    log_fail "Security Posture" "Detected $OPEN_MONITORING ports bound to 0.0.0.0"
fi

echo "========================================================================"
echo "SRE Validation Summary: ${PASSED_CHECKS}/${TOTAL_CHECKS} checks passed (${FAILED_CHECKS} failures)"
echo "========================================================================"

if [ "$FAILED_CHECKS" -gt 0 ]; then
    echo "ERROR: SRE platform validation failed with $FAILED_CHECKS issue(s)." >&2
    exit 1
fi

echo "SUCCESS: PulseOps SRE platform validation PASSED all checks."
exit 0
