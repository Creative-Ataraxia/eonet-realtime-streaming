from confluent_kafka import Producer, KafkaException
from confluent_kafka.admin import AdminClient, NewTopic
import json
import time

class KafkaProducer:
    def __init__(self, bootstrap_servers: str, topic: str, retries: int = 5, backoff_seconds: int = 5):
        self.bootstrap_servers = bootstrap_servers
        self.topic = topic

        attempt = 0
        while attempt < retries:
            try:
                self.producer = Producer({'bootstrap.servers': self.bootstrap_servers})
                self._verify_kafka_connection()
                self._ensure_topic_exists()
                print("[dev log] Kafka producer connected and topic verified.")
                return
            except KafkaException as e:
                print(f"[dev log] Kafka connection failed: {e}")
                attempt += 1
                time.sleep(backoff_seconds)
        raise RuntimeError("Failed to connect to Kafka after multiple attempts.")

    def _verify_kafka_connection(self):
        self.producer.list_topics(timeout=5)

    def _ensure_topic_exists(self):
        admin_client = AdminClient({'bootstrap.servers': self.bootstrap_servers})
        metadata = admin_client.list_topics(timeout=5)

        if self.topic in metadata.topics:
            print(f"[dev log] Topic '{self.topic}' already exists.")
            return

        new_topic = [NewTopic(self.topic, num_partitions=3, replication_factor=1)]
        fs = admin_client.create_topics(new_topic)

        for topic, f in fs.items():
            try:
                f.result()
                print(f"[dev log] Topic '{topic}' created successfully.")
            except Exception as e:
                print(f"[dev log] Failed to create topic '{topic}': {e}")

    def produce(self, record: dict):
        payload = json.dumps(record).encode('utf-8')
        self.producer.produce(self.topic, payload)
        self.producer.flush()

    def close(self):
        self.producer.flush()
