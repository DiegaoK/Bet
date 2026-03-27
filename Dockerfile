FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY backend /app/backend
COPY frontend /app/frontend
COPY README.md /app/README.md

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Streamlit will bind to $PORT (set by most PaaS). Default 8501.
ENV PORT=8501 \
    API_BASE=http://127.0.0.1:8000 \
    DATA_DIR=/app/data \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false \
    STREAMLIT_TELEMETRY_ENABLED=false

EXPOSE 8501

CMD ["/app/start.sh"]

