#!/usr/bin/env bash

set -euo pipefail
# Stop on errors (-e), undefined vars (-u), and pipe failures (-o pipefail)

BASE="https://hackattic.com"
TOKEN="${HACKATTIC_TOKEN}"
DB="chall"
PGHOST="127.0.0.1"
PGUSER="postgres"
PGPASSWORD="pg"; export PGPASSWORD

# Wait until PostgreSQL service becomes ready
until pg_isready -h "$PGHOST" -U "$PGUSER" >/dev/null; do sleep 1; done

# Recreate database (terminate connections, drop if exists, create fresh)
psql -h "$PGHOST" -U "$PGUSER" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${DB}'" || true
psql -h "$PGHOST" -U "$PGUSER" -c "DROP DATABASE IF EXISTS ${DB};"
psql -h "$PGHOST" -U "$PGUSER" -c "CREATE DATABASE ${DB};"

# Fetch new problem dump → decode base64 → decompress gzip → restore into DB
curl -s "${BASE}/challenges/backup_restore/problem?access_token=${TOKEN}" \
 | jq -r .dump | base64 -d | gzip -d \
 | psql -h "$PGHOST" -U "$PGUSER" -d "$DB"

# Extract SSNs of records with status = 'alive' and format as JSON array
SSNS=$(psql -h "$PGHOST" -U "$PGUSER" -d "$DB" -t -A \
  -c "SELECT ssn FROM criminal_records WHERE status='alive';" \
  | jq -R -s 'split("\n")[:-1]')

# Submit solution back to Hackattic
curl -s -X POST "${BASE}/challenges/backup_restore/solve?access_token=${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"alive_ssns\": ${SSNS}}" | jq .
