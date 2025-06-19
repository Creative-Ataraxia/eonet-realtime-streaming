import time
from datetime import datetime, timezone
import requests
from producer import KafkaProducer

# Configs
EONET_API_URL = "https://eonet.gsfc.nasa.gov/api/v3/events"
POLL_INTERVAL_SECONDS = 3600  # poll every 1 hour
KAFKA_BOOTSTRAP = "kafka:9092"  # service name from docker-compose network
KAFKA_TOPIC = "eonet_raw"
MAX_RETRIES = 5
BACKOFF_FACTOR = 2  # seconds

def poll_eonet_api():
    attempt = 0
    while attempt < MAX_RETRIES:
        try:
            response = requests.get(EONET_API_URL, timeout=10)
            if response.status_code == 200:
                api_payload = response.json()
                return {
                    "source_ingest_timestamp": datetime.now(timezone.utc).isoformat(),
                    "payload": api_payload
                }
            else:
                print(f"[dev log] EONET API returned {response.status_code}")
        except requests.RequestException as e:
            print(f"[dev log] Request failed: {e}")
        
        attempt += 1
        wait_time = BACKOFF_FACTOR * (2 ** (attempt - 1))
        print(f"[dev log] Retrying in {wait_time} seconds...")
        time.sleep(wait_time)

    print("[dev log] All retries failed.")
    return None

def main():
    producer = KafkaProducer(KAFKA_BOOTSTRAP, KAFKA_TOPIC)

    while True:
        record = poll_eonet_api()
        if record:
            producer.produce(record)
            print(f"[dev log] Ingested new payload at {record['source_ingest_timestamp']}")

        time.sleep(POLL_INTERVAL_SECONDS)

if __name__ == "__main__":
    main()
