import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = "http://127.0.0.1:8008";

export const options = {
  // 강 부하: 실패 패턴과 꼬리 지연을 보기 위한 스트레스 테스트
  stages: [
    { duration: "30s", target: 50 },
    { duration: "2m", target: 150 },
    { duration: "30s", target: 0 },
  ],
  thresholds: {
    // 스트레스 상황에서 허용 에러율을 조금 늘리되, 안정성 지표는 유지
    http_req_failed: ["rate<0.02"],
    http_req_duration: ["p(95)<800"],
  },
};

export default function () {
  const endpoints = [
    { path: "/parkinglot", weight: 60 },
    { path: "/facility", weight: 20 },
    { path: "/parkinglot/live", weight: 20 },
  ];

  const pick = weightedPick(endpoints);
  const url = `${BASE_URL}${pick.path}`;
  const res = http.get(url, {
    tags: {
      endpoint: pick.path,
      test_level: "high",
    },
    // 로컬 기준 넉넉한 타임아웃
    timeout: "12s",
  });

  check(res, {
    "status is 200": (r) => r.status === 200,
  });

  sleep(1);
}

function weightedPick(items) {
  const total = items.reduce((sum, item) => sum + item.weight, 0);
  let r = Math.random() * total;
  for (const item of items) {
    r -= item.weight;
    if (r <= 0) return item;
  }
  return items[items.length - 1];
}
