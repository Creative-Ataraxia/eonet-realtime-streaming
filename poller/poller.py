import requests
import time
import os
from producer import KafkaProducer

POLL_MODE = os.getenv("POLL_MODE", "prod")
EONET_API_URL = "https://eonet.gsfc.nasa.gov/api/v3/events"
KAFKA_TOPIC = "eonet_raw"
POLL_INTERVAL_SECONDS = 3600  # For production; use shorter interval for testing

def poll_eonet():
    try:
        response = requests.get(EONET_API_URL)
        response.raise_for_status()
        data = response.json()
        print(f"[dev log] Successfully polled EONET API. {len(data['events'])} events received.")
        return data["events"]
    except requests.RequestException as e:
        print(f"[dev log] Error polling EONET API: {e}")
        return []

def main():
    bootstrap_servers = os.environ.get("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
    producer = KafkaProducer(bootstrap_servers, KAFKA_TOPIC)

    while True:
        events = poll_eonet()
        if POLL_MODE == "dev": events = events[:100]

        for event in events:
            try:
                producer.produce(event)
                print(f"[dev log] Event {event.get('id')} produced to Kafka.")
            except Exception as e:
                print(f"[dev log] Failed to produce event {event.get('id')}: {e}")
        print(f"[dev log] Poll cycle complete. Sleeping for {POLL_INTERVAL_SECONDS} seconds...\n")
        time.sleep(POLL_INTERVAL_SECONDS)

if __name__ == "__main__":
    main()
