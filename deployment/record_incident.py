#!/usr/bin/env python3
"""
PulseOps Durable Incident & MTTR Recorder
Records incident recovery events to an append-only JSONL log and generates
Prometheus textfile metrics for actual measured MTTR.
"""

import argparse
import json
import os
import time
from datetime import datetime, timezone

BASE_DIR = os.getenv(
    "PULSEOPS_BASE_REPO_DIR",
    "/home/ubuntu/PulseOps" if os.path.exists("/home/ubuntu/PulseOps") else os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
)
DEPLOYMENTS_DIR = os.getenv("PULSEOPS_DEPLOYMENTS_DIR", "/home/ubuntu/pulseops-deployments")
if not os.path.exists(DEPLOYMENTS_DIR) and not os.access(os.path.dirname(DEPLOYMENTS_DIR) or ".", os.W_OK):
    DEPLOYMENTS_DIR = os.path.join(BASE_DIR, "deployment", "data")
INCIDENT_FILE = f"{DEPLOYMENTS_DIR}/incident_history.jsonl"
PROM_FILE = f"{BASE_DIR}/monitoring/textfile_metrics/incidents.prom"

os.makedirs(DEPLOYMENTS_DIR, exist_ok=True)
os.makedirs(os.path.dirname(PROM_FILE), exist_ok=True)

def record_incident(incident_id, title, severity, duration):
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    now_ts = int(time.time())

    event = {
        "incident_id": incident_id,
        "timestamp": now_iso,
        "timestamp_epoch": now_ts,
        "title": title,
        "severity": severity,
        "duration_seconds": round(float(duration), 2)
    }

    with open(INCIDENT_FILE, "a") as f:
        f.write(json.dumps(event) + "\n")

    durations = []
    sev_counts = {"SEV-1": 0, "SEV-2": 0, "SEV-3": 0}
    last_duration = 0.0

    if os.path.exists(INCIDENT_FILE):
        with open(INCIDENT_FILE, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    e = json.loads(line)
                    dur = float(e.get("duration_seconds", 0.0))
                    durations.append(dur)
                    last_duration = dur
                    sev = e.get("severity", "SEV-2")
                    if sev in sev_counts:
                        sev_counts[sev] += 1
                except Exception:
                    pass

    total_incidents = len(durations)
    mttr = round(sum(durations) / total_incidents, 2) if total_incidents > 0 else 0.0

    tmp_prom = f"{PROM_FILE}.tmp"
    prom_content = f"""# HELP pulseops_incident_events_total Total recorded resolved incidents
# TYPE pulseops_incident_events_total counter
pulseops_incident_events_total{{severity="SEV-1"}} {sev_counts['SEV-1']}
pulseops_incident_events_total{{severity="SEV-2"}} {sev_counts['SEV-2']}
pulseops_incident_events_total{{severity="SEV-3"}} {sev_counts['SEV-3']}

# HELP pulseops_incident_recovery_mttr_seconds Mean Time to Recovery in seconds across recorded incidents
# TYPE pulseops_incident_recovery_mttr_seconds gauge
pulseops_incident_recovery_mttr_seconds {mttr}

# HELP pulseops_incident_last_recovery_seconds Recovery duration of most recent resolved incident
# TYPE pulseops_incident_last_recovery_seconds gauge
pulseops_incident_last_recovery_seconds {last_duration}

# HELP pulseops_incident_count_total Total count of incidents evaluated in MTTR baseline
# TYPE pulseops_incident_count_total gauge
pulseops_incident_count_total {total_incidents}
"""
    with open(tmp_prom, "w") as f:
        f.write(prom_content)
    os.replace(tmp_prom, PROM_FILE)
    print(f"Recorded incident {incident_id} [{severity}] ({duration}s). MTTR: {mttr}s (Sample size: {total_incidents}).")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--id", required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--severity", required=True, choices=["SEV-1", "SEV-2", "SEV-3"])
    parser.add_argument("--duration", required=True, type=float)
    args = parser.parse_args()

    record_incident(args.id, args.title, args.severity, args.duration)
