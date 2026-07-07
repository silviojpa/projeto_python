FROM python:3.10-slim

WORKDIR /app

# Copia o requirements.txt e o app.py para dentro do container
COPY . .

# Instala o Flask diretamente no escopo do container
RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
