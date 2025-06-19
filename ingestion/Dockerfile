FROM python:3.10-slim

# Install system dependencies (optional for prod stability)
RUN apt-get update && apt-get install -y gcc

# Create working directory
WORKDIR /app

# Copy requirements first to leverage Docker caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY . .

# Default entrypoint (can be overridden for cron testing)
CMD ["python", "poller.py"]
