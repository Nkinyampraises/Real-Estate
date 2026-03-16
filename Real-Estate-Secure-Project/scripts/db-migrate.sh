#!/usr/bin/env bash
set -euo pipefail

HOST=${PGHOST:-localhost}
PORT=${PGPORT:-5432}
DATABASE=${PGDATABASE:-real_estate_secure}
USER=${PGUSER:-postgres}
PASSWORD=${PGPASSWORD:-postgres}

export PGPASSWORD="$PASSWORD"

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MIGRATIONS_DIR="$ROOT_DIR/database/migrations"
SEEDS_DIR="$ROOT_DIR/database/seeds"

echo "Running migrations from $MIGRATIONS_DIR"
for file in $(ls "$MIGRATIONS_DIR"/*.sql | sort); do
  echo "Applying $(basename "$file")"
  psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DATABASE" -v ON_ERROR_STOP=1 -f "$file"
done

echo "Running seeds from $SEEDS_DIR"
for file in $(ls "$SEEDS_DIR"/*.sql | sort); do
  echo "Seeding $(basename "$file")"
  psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DATABASE" -v ON_ERROR_STOP=1 -f "$file"
done
