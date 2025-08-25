# Usar imagem base oficial do Python
FROM python:3.12-slim

# Criar diretório da aplicação
WORKDIR /app

# Instalar dependências
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY app .

# Rodar servidor uvicorn (host 0.0.0.0 para expor no container)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
