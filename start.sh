#!/usr/bin/env bash
set -euo pipefail

echo "[start] PORT=${PORT}"
echo "[start] DATA_DIR=${DATA_DIR}"
echo "[start] API_BASE=${API_BASE}"

mkdir -p "${DATA_DIR}"

# Generate dataset if missing (fast enough for MVP)
if [[ ! -f "${DATA_DIR}/users.csv" ]]; then
  echo "[start] dataset not found; generating..."
  python -m backend.generate_data --out "${DATA_DIR}" --seed 42 --days 180
else
  echo "[start] dataset found; skipping generation."
fi

# Start backend (internal)
echo "[start] starting backend on :8000"
uvicorn backend.api:app --host 0.0.0.0 --port 8000 &
BACK_PID=$!

cleanup() {
  echo "[start] shutting down..."
  kill "${BACK_PID}" 2>/dev/null || true
}
trap cleanup EXIT

sleep 1

# Start Streamlit (public)
echo "[start] starting dashboard on :${PORT}"
exec streamlit run frontend/app.py \
  --server.headless true \
  --server.address 0.0.0.0 \
  --server.port "${PORT}"

