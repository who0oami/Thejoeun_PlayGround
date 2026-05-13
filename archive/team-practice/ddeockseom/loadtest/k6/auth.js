import http from "k6/http";
import { check, sleep } from "k6";

const BASE_URL = "http://127.0.0.1:8008";
const ADMIN_ID = __ENV.ADMIN_ID || "";
const ADMIN_PASSWORD = __ENV.ADMIN_PASSWORD || "";

export const options = {
  // 로그인 흐름 안정성 확인을 위한 인증 전용 테스트
  stages: [
    { duration: "20s", target: 10 },
    { duration: "1m", target: 30 },
    { duration: "20s", target: 0 },
  ],
  thresholds: {
    http_req_failed: ["rate<0.02"],
    http_req_duration: ["p(95)<500"],
  },
};

export default function () {
  if (!ADMIN_ID || !ADMIN_PASSWORD) {
    throw new Error("Set ADMIN_ID and ADMIN_PASSWORD env vars before running auth.js");
  }

  const url = `${BASE_URL}/v1/auth/login`;
  const payload = JSON.stringify({
    id: ADMIN_ID,
    password: ADMIN_PASSWORD,
  });

  const res = http.post(url, payload, {
    headers: { "Content-Type": "application/json" },
    tags: {
      endpoint: "/v1/auth/login",
      test_level: "auth",
    },
    // 로컬 기준 넉넉한 타임아웃
    timeout: "10s",
  });

  check(res, {
    "status is 200": (r) => r.status === 200,
  });

  sleep(1);
}
