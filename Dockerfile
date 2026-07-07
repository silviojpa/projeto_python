FROM python:3.10-slim

WORKDIR /app

# Atualiza a lista de pacotes e instala as correções de segurança disponíveis
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
