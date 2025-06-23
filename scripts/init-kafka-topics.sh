#!/bin/sh
set -e

create_topic() {
  local topic=$1
  echo "Creating topic: $topic"
  /opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka-broker:9092 \
    --create --if-not-exists --topic "$topic" --partitions 3 --replication-factor 1
}

# retry loop to ensure broker is fully ready
for i in $(seq 1 30); do
  if /opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server kafka-broker:9092 --list > /dev/null 2>&1; then
    echo "kafka-broker is responding."
    break
  fi
  echo "Kafka-broker not ready yet... retry $i"
  sleep 2
done

# Create topics
create_topic "eonet_flattened"
create_topic "eonet_dlq"
create_topic "eonet_cleaned"

echo "Kafka topic initialization complete."
