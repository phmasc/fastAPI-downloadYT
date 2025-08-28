# Usar imagem base oficial do Python
FROM python:3.12-slim

# Variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/home/appuser/.local/bin:$PATH"

# Diretório de trabalho
WORKDIR /app

# Usuário não-root
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app
USER appuser

# Dependências
COPY --chown=appuser:appuser app/requirements.txt .
RUN if [ -s requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; fi

# Código da aplicação
COPY --chown=appuser:appuser app .

# Porta exposta
EXPOSE 8000

# Labels OCI (metadados da imagem)
LABEL org.opencontainers.image.title="fastapi-hello" \
      org.opencontainers.image.description="FastAPI Hello World example" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/SEU_USUARIO/SEU_REPO"

# Healthcheck opcional (só se tiver endpoint /health)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://127.0.0.1:8000/health || exit 1

# Comando padrão
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
