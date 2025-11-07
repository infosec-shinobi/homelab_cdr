#!/bin/bash
set -euo pipefail

# -------------------------------------------------------------------
# NimbusGuard Healthcheck Utility
# -------------------------------------------------------------------
# Checks the availability of all major services in the NimbusGuard
# stack and reports their status. Exits non-zero if any service fails.
#
# Usage:
#   ./scripts/healthcheck.sh
# -------------------------------------------------------------------

# === CONFIGURATION ===
SERVICES=(
  "grafana:http://localhost:3000/api/health"
  "prometheus:http://localhost:9090/-/healthy"
  "n8n:http://localhost:5678/metrics"
  "tracecat:http://localhost:8080/health"
  "wazuh-dashboard:http://localhost:5601"
)

# Optional log file
LOG_FILE="./healthcheck.log"

# Optional Slack webhook (leave blank to disable)
SLACK_WEBHOOK_URL=""

# Timestamp
NOW=$(date +"%Y-%m-%d %H:%M:%S")

# ANSI colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Track failures
FAILED=()

echo "🩺 NimbusGuard Health Check - ${NOW}" | tee -a "$LOG_FILE"
echo "-----------------------------------------------------" | tee -a "$LOG_FILE"

for entry in "${SERVICES[@]}"; do
  NAME="${entry%%:*}"
  URL="${entry#*:}"

  # Use curl with timeout and silent mode
  if curl -fs --max-time 5 "$URL" >/dev/null 2>&1; then
    echo -e "✅ ${GREEN}${NAME}${RESET} is healthy (${URL})" | tee -a "$LOG_FILE"
  else
    echo -e "❌ ${RED}${NAME}${RESET} is unreachable (${URL})" | tee -a "$LOG_FILE"
    FAILED+=("$NAME")
  fi
done

# --------------------------------------------------------------
# Optional Wazuh deeper check (ensure API responds)
# --------------------------------------------------------------
if curl -fs --max-time 5 "http://localhost:55000" >/dev/null 2>&1; then
  echo -e "✅ ${GREEN}wazuh-manager${RESET} API reachable" | tee -a "$LOG_FILE"
else
  echo -e "❌ ${RED}wazuh-manager${RESET} API failed" | tee -a "$LOG_FILE"
  FAILED+=("wazuh-manager")
fi

# --------------------------------------------------------------
# Final summary
# --------------------------------------------------------------
if [ ${#FAILED[@]} -eq 0 ]; then
  echo -e "\n🎉 ${GREEN}All NimbusGuard services are healthy.${RESET}" | tee -a "$LOG_FILE"
  STATUS="healthy"
else
  echo -e "\n⚠️  ${RED}Some services failed health check:${RESET} ${FAILED[*]}" | tee -a "$LOG_FILE"
  STATUS="degraded"
fi

# --------------------------------------------------------------
# Optional: Post to Slack (if webhook configured)
# --------------------------------------------------------------
if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
  STATUS_EMOJI=":white_check_mark:"
  if [ "$STATUS" != "healthy" ]; then
    STATUS_EMOJI=":x:"
  fi

  MESSAGE="NimbusGuard Health Check (${NOW}): ${STATUS_EMOJI}\nFailed: ${FAILED[*]:-none}"

  curl -X POST -H 'Content-type: application/json' \
    --data "{\"text\": \"${MESSAGE}\"}" \
    "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 || echo "⚠️ Slack alert failed."
fi

# Exit non-zero if failures
if [ ${#FAILED[@]} -ne 0 ]; then
  exit 1
fi
