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


Check the health of the kafka-to-postgres module:
1) after `docker compose up`, `docker compose ps`, see if all 4 services are running: `kafka-broker, kafka-connect , kafka-ui, postgres`
2) check jdbc-sink-connector's status, make sure it's `running`:
    - `curl http://localhost:8083/connectors/postgres-sink-connector/status | jq`
3) exec into postgres and check tables; `\dt` to show all tables
    - `docker exec -it postgres psql -U postgres -d eonet`
    - remember in postgres SQL statements needs to end with `;` to run
4) check if kafka-UI is running correctly: `http://localhost:8080/`
    - check in `consumer`, `connect-postgres-sink-connector` is "stable"
5) check sink connector's `insert.mode` setting:
    - `curl http://localhost:8083/connectors/postgres-sink-connector/config | jq`
    - if for some reason the config is wrong (pay attention to `insert.mode`); then delete & re-create connector
6) try producing a message (don't use the UI!) into `eonet_raw` and see if it shows up in postgres