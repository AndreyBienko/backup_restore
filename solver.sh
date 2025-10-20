#!/usr/bin/env bash
set -euo pipefail

BASE="https://hackattic.com"
TOKEN="${HACKATTIC_TOKEN}"
DB="chall"
PGHOST="127.0.0.1"
PGUSER="postgres"
PGPASSWORD="pg"; export PGPASSWORD


until pg_isready -h "$PGHOST" -U "$PGUSER" >/dev/null; do sleep 1; done


psql -h "$PGHOST" -U "$PGUSER" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${DB}'" || true
psql -h "$PGHOST" -U "$PGUSER" -c "DROP DATABASE IF EXISTS ${DB};"
psql -h "$PGHOST" -U "$PGUSER" -c "CREATE DATABASE ${DB};"


curl -s "${BASE}/challenges/backup_restore/problem?access_token=${TOKEN}" \
 | jq -r .dump | base64 -d | gzip -d \
 | psql -h "$PGHOST" -U "$PGUSER" -d "$DB"


SSNS=$(psql -h "$PGHOST" -U "$PGUSER" -d "$DB" -t -A \
  -c "SELECT ssn FROM criminal_records WHERE status='alive';" \
  | jq -R -s 'split("\n")[:-1]')


curl -s -X POST "${BASE}/challenges/backup_restore/solve?access_token=${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"alive_ssns\": ${SSNS}}" | jq .
