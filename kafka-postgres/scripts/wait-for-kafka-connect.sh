#!/bin/sh

echo "[wait-for-kafka-connect] Waiting for Kafka Connect REST API..."

# Wait up to 120 seconds (change as you wish)
for i in $(seq 1 120); do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://kafka-connect:8083/connectors)
    if [ "$HTTP_CODE" -eq "200" ]; then
        echo "[wait-for-kafka-connect] Kafka Connect REST API is available!"
        exit 0
    else
        echo "[wait-for-kafka-connect] Waiting... ($i)"
        sleep 2
    fi
done

echo "[wait-for-kafka-connect] Timeout waiting for Kafka Connect"
exit 1
