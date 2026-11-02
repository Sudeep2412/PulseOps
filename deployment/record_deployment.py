#!/usr/bin/env python3
"""
PulseOps Durable Deployment Event Recorder
Records deployment attempts to an append-only JSONL log and generates
Prometheus textfile metrics consumed by Node Exporter.
"""

import argparse
import json
import os
import time
from datetime import datetime, timezone

BASE_DIR = os.getenv("PULSEOPS_BASE_REPO_DIR", "/home/ubuntu/PulseOps")
DEPLOYMENTS_DIR = "/home/ubuntu/pulseops-deployments"
HISTORY_FILE = f"{DEPLOYMENTS_DIR}/deployments_history.jsonl"
PROM_FILE = f"{BASE_DIR}/monitoring/textfile_metrics/deployments.prom"

os.makedirs(DEPLOYMENTS_DIR, exist_ok=True)
os.makedirs(os.path.dirname(PROM_FILE), exist_ok=True)

def record_event(status, commit_sha, duration=0.0):
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    now_ts = int(time.time())

    event = {
        "timestamp": now_iso,
        "timestamp_epoch": now_ts,
        "commit_sha": commit_sha,
        "status": status,
        "duration_seconds": round(float(duration), 2)
    }

    with open(HISTORY_FILE, "a") as f:
        f.write(json.dumps(event) + "\n")

    success_count = 0
    failed_count = 0
    rollback_count = 0
    last_success_ts = 0
    last_duration = 0.0

    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    e = json.loads(line)
                    st = e.get("status")
                    if st == "success":
                        success_count += 1
                        last_success_ts = e.get("timestamp_epoch", 0)
                        last_duration = e.get("duration_seconds", 0.0)
                    elif st == "rollback":
                        rollback_count += 1
                    elif st == "failed":
                        failed_count += 1
                except Exception:
                    pass

    tmp_prom = f"{PROM_FILE}.tmp"
    prom_content = f"""# HELP pulseops_deployment_events_total Total deployments executed by status
# TYPE pulseops_deployment_events_total counter
pulseops_deployment_events_total{{status="success"}} {success_count}
pulseops_deployment_events_total{{status="failed"}} {failed_count}
pulseops_deployment_events_total{{status="rollback"}} {rollback_count}

# HELP pulseops_deployment_last_timestamp_seconds Epoch timestamp of last successful deployment
# TYPE pulseops_deployment_last_timestamp_seconds gauge
pulseops_deployment_last_timestamp_seconds{{status="success"}} {last_success_ts}

# HELP pulseops_deployment_last_duration_seconds Execution duration of last deployment in seconds
# TYPE pulseops_deployment_last_duration_seconds gauge
pulseops_deployment_last_duration_seconds {last_duration}
"""
    with open(tmp_prom, "w") as f:
        f.write(prom_content)
    os.replace(tmp_prom, PROM_FILE)
    print(f"Recorded deployment event '{status}' for commit {commit_sha} ({duration}s).")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--status", required=True, choices=["success", "failed", "rollback"])
    parser.add_argument("--sha", required=True)
    parser.add_argument("--duration", default=0.0, type=float)
    args = parser.parse_args()

    record_event(args.status, args.sha, args.duration)
