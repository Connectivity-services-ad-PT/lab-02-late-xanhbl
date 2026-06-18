#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:4010}"
AUTH_HEADER="Authorization: Bearer test-token"

echo "[Lab02 Pair 03] Testing Prism mock server at $BASE_URL"
echo

echo "[1/5] Happy path: GET /health"
curl -i "$BASE_URL/health"
echo -e "\n---"

echo "[2/5] Happy path: GET /access/logs/recent"
curl -i "$BASE_URL/access/logs/recent?limit=10" -H "$AUTH_HEADER" -H "X-Correlation-Id: 0197a41f-9f20-72e0-a815-8a50eafdb999"
echo -e "\n---"

echo "[3/5] Happy path: GET /gates/GATE-01/status"
curl -i "$BASE_URL/gates/GATE-01/status" -H "$AUTH_HEADER"
echo -e "\n---"

echo "[4/5] Error path: force 404 GET /cards/CARD-2026-999999"
curl -i "$BASE_URL/cards/CARD-2026-999999" -H "$AUTH_HEADER" -H "Prefer: code=404"
echo -e "\n---"

echo "[5/5] Error path: force 400 GET /cards/CARD-INVALID"
curl -i "$BASE_URL/cards/CARD-INVALID" -H "$AUTH_HEADER" -H "Prefer: code=400"
echo
