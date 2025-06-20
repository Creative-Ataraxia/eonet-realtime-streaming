FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN apt-get update && apt-get install -y gcc && pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "poller.py"]
