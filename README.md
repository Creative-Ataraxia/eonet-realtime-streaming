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


Check the healthy of the overall pipeline:
1) check the status of kafka connector
    - `curl http://localhost:8083/connectors/postgres-sink-connector/status | jq`
2) check kafka UI; topics, consumers
    - `http://localhost:8080/ui/clusters/local/all-topics`
3) check postgres; `\dt` to show all tables
    - `docker exec -it postgres psql -U postgres -d eonet`
4) try producing a mock message via kafka UI into `eonet_test` and check if shows up in postgres
    ```json
    {
        "schema": {
            "type": "struct",
            "fields": [
            { "field": "id", "type": "string" },
            { "field": "title", "type": "string" },
            { "field": "category_title", "type": "string" },
            { "field": "magnitude", "type": "double" },
            { "field": "magnitude_unit", "type": "string" },
            { "field": "geom_date", "type": "int64", "name": "org.apache.kafka.connect.data.Timestamp" },
            { "field": "lon", "type": "double" },
            { "field": "lat", "type": "double" },
            { "field": "processed_time", "type": "int64", "name": "org.apache.kafka.connect.data.Timestamp" }
            ],
            "optional": false,
            "name": "eonet_cleaned_schema"
        },
        "payload": {
            "id": "MOCK_124",
            "title": "Mock Event",
            "category_title": "Mock",
            "magnitude": 100.0,
            "magnitude_unit": "mock",
            "geom_date": 1750656000000,
            "lon": -117.2,
            "lat": 44.28,
            "processed_time": 1750579200000
        }
    }
    ```
    in postgres: `select * from eonet_test;`
5) after submitting flink sql jobs, check flink UI for job status:
    - `http://localhost:8081/#/overview`


during pipeline debugging, to reset status:

1) delete all messages from topics via UI

2) delete & reset sink connector
    - `curl -X DELETE http://localhost:8083/connectors/postgres-sink-connector`
    - `curl -X POST http://localhost:8083/connectors -H 'Content-Type: application/json' --data-binary @/home/roy/projects/eonet/kafka-postgres/kafka-init/connect-jdbc-sink.json`
    - check if connects tasks for 'running' status
        - `curl http://localhost:8083/connectors/postgres-sink-connector/status | jq`

3) cancel all currently running flink job via UI

4) then, post all flink jobs again to continue debugging (check sql codes are the most current ones)
    - `cat /opt/sql/full-job.sql`
    - `./bin/sql-client.sh -f /opt/sql/full-job.sql`