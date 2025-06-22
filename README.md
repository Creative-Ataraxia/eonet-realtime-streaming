Near-real-time streaming ingestion. "bursty events ingestion"
Ingest raw → deduplicate later → enrich → serve.
    "Ingest everything, deduplicate later."


workflow:

1) Start App: `docker compose up`
2) Exec into Flink's container: `docker exec -it flink-jobmanager /bin/bash`
3) Submit all Flink Jobs: `./bin/sql-client.sh -f /opt/sql/full-job.sql`
4) Verify from Flink's UI that all jobs are running: `http://localhost:8081/#/overview`

start fresh workflow:

0) backup current kafka volume: `docker run --rm -v eonet_kafka-data:/data -v $PWD/kafka-backup:/backup busybox sh -c "cp -r /data/* /backup/"`
1) Remove the kafka volume completely: `docker volume rm eonet_kafka-data`
2) Start App: `docker compose up`
3) Exec into Kafka's container: `docker exec -it kafka-broker /bin/bash`
4) Get into the right bin folder: `cd /opt/bitnami/kafka/bin`
5) Sanity check, list current topics: `./kafka-topics.sh --bootstrap-server localhost:9092 --list`
6) Create all topics manually: `./kafka-topics.sh --bootstrap-server localhost:9092 --create --topic eonet_flattened && ./kafka-topics.sh --bootstrap-server localhost:9092 --create --topic eonet_dlq && ./kafka-topics.sh --bootstrap-server localhost:9092 --create --topic eonet_cleaned`
7) Exec into Flink's container: `docker exec -it flink-jobmanager /bin/bash`
8) Submit all Flink Jobs: `./bin/sql-client.sh -f /opt/sql/full-job.sql`
9) Verify from Flink's UI that all jobs are running: `http://localhost:8081/#/overview`