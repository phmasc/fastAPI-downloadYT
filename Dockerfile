# Base oficial do Python
FROM python:3.12-slim

# Variáveis de ambiente para otimizar Python e pip
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/home/appuser/.local/bin:$PATH"

# Diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema (curl para healthcheck)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Criar usuário não-root
RUN adduser --disabled-password --gecos "" appuser \
    && chown -R appuser:appuser /app \
    && mkdir -p /app/media \
    && chown -R appuser:appuser /app/media \
    && chmod u+rwx /app/media
USER appuser

# Instalar dependências da aplicação
COPY --chown=appuser:appuser app/requirements.txt .
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Copiar código da aplicação
COPY --chown=appuser:appuser app .

# Expor porta
EXPOSE 8000

# Labels OCI (metadados)
LABEL org.opencontainers.image.title="fastapi-hello" \
      org.opencontainers.image.description="FastAPI Hello World example" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/phmasc/fastAPI-downloadYT"

# Healthcheck (bate na rota /health)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://127.0.0.1:8000/health || exit 1

# Comando padrão (produção)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
