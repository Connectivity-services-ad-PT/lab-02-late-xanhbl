$ErrorActionPreference = "Stop"

$BaseUrl = if ($env:BASE_URL) { $env:BASE_URL } else { "http://localhost:4010" }
$AuthHeader = "Authorization: Bearer test-token"

Write-Host "[Lab02 Pair 03] Testing Prism mock server at $BaseUrl"
Write-Host ""

Write-Host "[1/5] Happy path: GET /health"
curl.exe -i "$BaseUrl/health"
Write-Host "`n---"

Write-Host "[2/5] Happy path: GET /access/logs/recent"
curl.exe -i "$BaseUrl/access/logs/recent?limit=10" -H $AuthHeader -H "X-Correlation-Id: 0197a41f-9f20-72e0-a815-8a50eafdb999"
Write-Host "`n---"

Write-Host "[3/5] Happy path: GET /gates/GATE-01/status"
curl.exe -i "$BaseUrl/gates/GATE-01/status" -H $AuthHeader
Write-Host "`n---"

Write-Host "[4/5] Error path: force 404 GET /cards/CARD-2026-999999"
curl.exe -i "$BaseUrl/cards/CARD-2026-999999" -H $AuthHeader -H "Prefer: code=404"
Write-Host "`n---"

Write-Host "[5/5] Error path: force 400 GET /cards/CARD-INVALID"
curl.exe -i "$BaseUrl/cards/CARD-INVALID" -H $AuthHeader -H "Prefer: code=400"
Write-Host ""
