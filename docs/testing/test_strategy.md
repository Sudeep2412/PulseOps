# PulseOps Testing Strategy

## 1. Testing Pyramid
PulseOps implements a multi-tiered testing strategy:

1. **Unit Testing (Pytest)**:
   - Validates individual Flask routes (`/health`, `/ready`, `/metrics`, `/api/v1/*`), error handlers, and Prometheus instrumentation.
   - Requirement: Minimum 80% code coverage (Enforced via `--cov-fail-under=80`).
2. **Frontend Testing (Node Test Runner)**:
   - Validates SRE policy logic (GREEN, YELLOW, RED), SLI ratio formatting, and deployment commit truncation.
3. **Observability Unit Testing (Promtool)**:
   - Evaluates PromQL recording and alerting rules against 6 deterministic synthetic time-series test vectors.
4. **End-to-End SRE Platform Validation (`validate_sre.sh`)**:
   - Automated 21-point verification script validating live container states, Prometheus scrape target health, Alertmanager clustering, and loopback security.
