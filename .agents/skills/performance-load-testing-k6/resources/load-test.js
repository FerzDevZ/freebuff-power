// Production Grafana k6 Load Test Script
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 50 },  // Ramp-up to 50 VUs
    { duration: '1m', target: 50 },   // Stay at 50 VUs
    { duration: '30s', target: 0 },   // Ramp-down to 0
  ],
  thresholds: {
    http_req_failed: ['rate<0.01'],        // Less than 1% errors
    http_req_duration: ['p(95)<300'],      // 95% of requests under 300ms
  },
};

export default function () {
  const url = __ENV.TARGET_URL || 'http://localhost:8080/health';
  const res = http.get(url);

  check(res, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}
