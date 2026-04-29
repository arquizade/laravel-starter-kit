#!/bin/bash

set -uo pipefail

DC="docker compose"
PASS=0
FAIL=0
ERRORS=()

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAIL=$((FAIL + 1))
    ERRORS+=("$1")
}

section() {
    echo ""
    echo -e "${YELLOW}──────────────────────────────────────────${NC}"
    echo -e "${YELLOW} $1${NC}"
    echo -e "${YELLOW}──────────────────────────────────────────${NC}"
}

container_running() {
    local SERVICE=$1
    $DC ps --format json 2>/dev/null \
        | grep -i "\"Service\":\"$SERVICE\"" \
        | grep -qi "\"State\":\"running\""
}

# ─── 1. All containers running ────────────────────────────────────────────────
section "1. Container status"
SERVICES=("app" "nginx" "postgres" "pgadmin" "redis" "queue" "scheduler" "mailpit" "node")
for SERVICE in "${SERVICES[@]}"; do
    if container_running "$SERVICE"; then
        pass "Container '$SERVICE' is running"
    else
        fail "Container '$SERVICE' is not running"
    fi
done

# ─── 2. Laravel welcome page ──────────────────────────────────────────────────
section "2. Laravel app (HTTP)"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    pass "Laravel app responds with HTTP 200"
else
    fail "Laravel app returned HTTP $HTTP_CODE (expected 200)"
fi

# ─── 3. Database connection ───────────────────────────────────────────────────
section "3. Database connection"
if $DC exec -T app php artisan db:show > /dev/null 2>&1; then
    pass "Laravel can connect to PostgreSQL"
else
    fail "Laravel cannot connect to PostgreSQL"
fi

# ─── 4. pgAdmin ───────────────────────────────────────────────────────────────
section "4. pgAdmin"
PGADMIN_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5050 2>/dev/null || echo "000")
if [ "$PGADMIN_CODE" = "200" ] || [ "$PGADMIN_CODE" = "302" ]; then
    pass "pgAdmin is reachable at http://localhost:5050"
else
    fail "pgAdmin returned HTTP $PGADMIN_CODE (expected 200 or 302)"
fi

# ─── 5. Redis ─────────────────────────────────────────────────────────────────
section "5. Redis"
REDIS_RESPONSE=$($DC exec -T redis redis-cli ping 2>/dev/null | tr -d '[:space:]' || echo "")
if [ "$REDIS_RESPONSE" = "PONG" ]; then
    pass "Redis responds to PING with PONG"
else
    fail "Redis did not respond with PONG (got: '$REDIS_RESPONSE')"
fi

# ─── 6. Queue worker ──────────────────────────────────────────────────────────
section "6. Queue worker"
QUEUE_LOGS=$($DC logs queue --tail=20 2>/dev/null || echo "")
if echo "$QUEUE_LOGS" | grep -qi "error\|exception\|failed to connect"; then
    fail "Queue worker logs contain errors"
else
    pass "Queue worker logs look clean"
fi

# ─── 7. Scheduler ─────────────────────────────────────────────────────────────
section "7. Scheduler"
SCHEDULER_LOGS=$($DC logs scheduler --tail=20 2>/dev/null || echo "")
if echo "$SCHEDULER_LOGS" | grep -qi "error\|exception\|failed to connect"; then
    fail "Scheduler logs contain errors"
else
    pass "Scheduler logs look clean"
fi

# ─── 8. Mailpit UI ────────────────────────────────────────────────────────────
section "8. Mailpit"
MAILPIT_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8025 2>/dev/null || echo "000")
if [ "$MAILPIT_CODE" = "200" ]; then
    pass "Mailpit UI is reachable at http://localhost:8025"
else
    fail "Mailpit UI returned HTTP $MAILPIT_CODE (expected 200)"
fi

# ─── 9. Mail delivery ─────────────────────────────────────────────────────────
section "9. Mail delivery"
$DC exec -T app php artisan tinker --execute="Mail::raw('test', fn(\$m) => \$m->to('test@test.com')->subject('Stack Test'));" > /dev/null 2>&1 || true
sleep 2
MAIL_COUNT=$(curl -s http://localhost:8025/api/v1/messages 2>/dev/null | grep -o '"total":[0-9]*' | cut -d: -f2 || echo "0")
if [ "${MAIL_COUNT:-0}" -gt "0" ] 2>/dev/null; then
    pass "Test email delivered to Mailpit"
else
    fail "No emails found in Mailpit after sending test mail"
fi

# ─── 10. Vite dev server ──────────────────────────────────────────────────────
section "10. Vite dev server"
VITE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 2>/dev/null || echo "000")
if [ "$VITE_CODE" = "200" ] || [ "$VITE_CODE" = "404" ]; then
    pass "Vite dev server is reachable at http://localhost:5173"
else
    fail "Vite dev server returned HTTP $VITE_CODE (expected 200 or 404)"
fi

# ─── 11. Playwright binary check ──────────────────────────────────────────────
section "11. Playwright binary"
PLAYWRIGHT_BIN=$($DC exec -T app sh -c "test -f /var/www/html/node_modules/.bin/playwright && echo found" 2>/dev/null || echo "")
if [ "$PLAYWRIGHT_BIN" = "found" ]; then
    pass "Playwright binary found at node_modules/.bin/playwright"
else
    fail "Playwright binary missing — run: make playwright-install"
fi

PLAYWRIGHT_CACHE=$($DC exec -T app sh -c "ls /usr/local/ms-playwright 2>/dev/null | grep -c chromium || echo 0" 2>/dev/null || echo "0")
if [ "${PLAYWRIGHT_CACHE:-0}" -gt "0" ] 2>/dev/null; then
    pass "Playwright Chromium browser cache found"
else
    fail "Playwright Chromium not installed — run: make playwright-install"
fi

# ─── 12. Pest full test suite ─────────────────────────────────────────────────
section "12. Pest full test suite"
if $DC exec -T app ./vendor/bin/pest --no-coverage 2>/dev/null; then
    pass "All tests passed (unit + browser)"
else
    fail "Pest test suite has failures"
fi

# ─── 13. Xdebug off by default ────────────────────────────────────────────────
section "13. Xdebug default state"
XDEBUG_STATUS=$($DC exec -T app php -r "echo ini_get('xdebug.mode');" 2>/dev/null || echo "")
if [ -z "$XDEBUG_STATUS" ] || [ "$XDEBUG_STATUS" = "off" ]; then
    pass "Xdebug is off by default"
else
    fail "Xdebug is active when it should be off (mode: $XDEBUG_STATUS)"
fi

# ─── 14. Xdebug toggles on ────────────────────────────────────────────────────
section "14. Xdebug toggle"
XDEBUG_MODE=debug $DC up -d app > /dev/null 2>&1
sleep 3
XDEBUG_ON=$($DC exec -T app php -r "echo ini_get('xdebug.mode');" 2>/dev/null || echo "")
XDEBUG_MODE=off $DC up -d app > /dev/null 2>&1
if [ "$XDEBUG_ON" = "debug" ]; then
    pass "Xdebug toggles on with XDEBUG_MODE=debug"
else
    fail "Xdebug did not activate with XDEBUG_MODE=debug (mode: ${XDEBUG_ON:-empty})"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}══════════════════════════════════════════${NC}"
echo -e "${YELLOW} Results: ${GREEN}${PASS} passed${NC} / ${RED}${FAIL} failed${NC}"
echo -e "${YELLOW}══════════════════════════════════════════${NC}"

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Failed checks:${NC}"
    for ERR in "${ERRORS[@]}"; do
        echo -e "  ${RED}✗${NC} $ERR"
    done
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}All checks passed. Your stack is healthy.${NC}"
echo ""
