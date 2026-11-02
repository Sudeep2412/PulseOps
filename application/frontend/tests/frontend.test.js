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
  assert.equal(truncateSha('45489f5efc96662fb93c43fef8280f4f53798cf2'), '45489f5efc');
});
