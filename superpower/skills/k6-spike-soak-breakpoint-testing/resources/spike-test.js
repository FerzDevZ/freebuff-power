import http from 'k6/http';
export const options = {
  stages: [{ duration: '10s', target: 2000 }, { duration: '1m', target: 2000 }, { duration: '10s', target: 0 }]
};
export default function () { http.get('http://test.k6.io'); }
