import test from 'node:test';
import assert from 'node:assert/strict';

test('SRE Policy calculation matches error budget thresholds', () => {
  const getPolicyState = (remainingPercent) => {
    if (remainingPercent >= 50.0) return 'GREEN';
    if (remainingPercent >= 20.0) return 'YELLOW';
    return 'RED';
  };

  assert.equal(getPolicyState(100.0), 'GREEN');
  assert.equal(getPolicyState(50.0), 'GREEN');
  assert.equal(getPolicyState(49.9), 'YELLOW');
  assert.equal(getPolicyState(20.0), 'YELLOW');
  assert.equal(getPolicyState(19.9), 'RED');
  assert.equal(getPolicyState(0.0), 'RED');
});

test('SLI availability compliance formatting', () => {
  const formatSLI = (ratio) => {
    if (ratio === null || ratio === undefined) return 'No Traffic (Idle)';
    return `${(ratio * 100).toFixed(2)}%`;
  };

  assert.equal(formatSLI(null), 'No Traffic (Idle)');
  assert.equal(formatSLI(0.999), '99.90%');
  assert.equal(formatSLI(0.995), '99.50%');
  assert.equal(formatSLI(0.95), '95.00%');
});

test('Measured P95 latency vs Latency SLO compliance formatting', () => {
  const formatMeasuredLatency = (ms) => {
    if (ms === null || ms === undefined) return 'Idle (< 5ms)';
    return `${ms.toFixed(2)} ms`;
  };

  const formatLatencyCompliance = (ratio) => {
    if (ratio === null || ratio === undefined) return '100.0%';
    return `${(ratio * 100).toFixed(1)}%`;
  };

  // Measured latency must format in milliseconds
  assert.equal(formatMeasuredLatency(4.75), '4.75 ms');
  assert.equal(formatMeasuredLatency(null), 'Idle (< 5ms)');

  // SLO compliance must format as percentage
  assert.equal(formatLatencyCompliance(1.0), '100.0%');
  assert.equal(formatLatencyCompliance(0.985), '98.5%');
  assert.notEqual(formatMeasuredLatency(4.75), formatLatencyCompliance(1.0));
});

test('Traffic throughput RPS formatting', () => {
  const formatTraffic = (rps) => `${(rps ?? 0).toFixed(2)} RPS`;
  assert.equal(formatTraffic(2.326), '2.33 RPS');
  assert.equal(formatTraffic(0), '0.00 RPS');
  assert.equal(formatTraffic(null), '0.00 RPS');
});

test('SLO compliance determination', () => {
  const isCompliant = (ratio, targetPercent) => {
    if (ratio === null) return true; // Idle is compliant
    return (ratio * 100) >= targetPercent;
  };

  assert.equal(isCompliant(1.0, 99.5), true);
  assert.equal(isCompliant(0.995, 99.5), true);
  assert.equal(isCompliant(0.9949, 99.5), false);
  assert.equal(isCompliant(null, 99.5), true);
});

test('Deployment SHA formatting', () => {
  const truncateSha = (sha) => sha.slice(0, 10);
  assert.equal(truncateSha('c4c4074a44dd7bb78be03aaf36744308eafdd284'), 'c4c4074a44');
});
