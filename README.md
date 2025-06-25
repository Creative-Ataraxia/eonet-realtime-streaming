# **Real-Time Streaming Pipeline & Visualizations for NASA's natural events**

<br>
## **Overview**

This is a real-time streaming data engineering project; The pipeline ingests, transforms, persists, and visualize data about real-time natural events sourced from NASA's *eonet* APIs; Techs used are: `Kafka`, `Flink`, `Postgres`, `Mapbox`, and orchestrated using `Docker` Compose; I also wrote custom connectors and microservices in `Python` and `Java` to improve data flow and optimize real-time processing. This end-to-end data engineering project follows the industry's best practice patterns for ingesting *bursty* real-time data, apply streaming transformations, sink into storage, and consume with live-refresh less than 2,000ms;

### **Tech Stack**

* Custom connectors source from external APIs and produce into staging `Kafka` topics; written in `Python`
* `Flink` jobs for cleaning and transformation in real-time; Processed data sinked into intermediary `Kafka` topics; written in `Flink SQL`
* `Postgres` DBs to persist transformed data, streamed via custom JDBC `Kafka connectors`; written in `Java`
* `Kafka` serves as data bus, enabling queuing, parallel processing, and fault tolerance
* `Kafka-Connect` used to stream data between `Kafka` topics and other services
* `Docker` compose used to orchestrate pipeline; This project can easily be integrated into Airflow DAGs and deployed within Kubernetes clusters
* `Mapbox` is used to visualize the the geojson data by overlaying on an interactive world map.

---

## **Architecture**

![Image](https://github.com/Creative-Ataraxia/Creative-Ataraxia/blob/main/img/4.%20real-time%20analytics%20v3.png)

### **Components**

1. **Kafka**
   * Kafka serves as the message broker between the data producers (custom sourcing) and the data consumers (`Flink`, `Kafka Connect` -> `Postgres`).
   * Main `Kafka` Topics: `eonet_raw`, `eonet_flattened`, `eonet_dlq`, `eonet_cleaned`.

2. **Apache Flink**
   * `Flink` performs real-time stream processing via `Flink` SQL jobs, including cleaning, transformation, and enrichment.
   * `Flink` SQL Jobs: Read data from `Kafka` staging topics, process it, and write the cleaned data to downstream `Kafka` topics.
   * use `Flink UI` for monitoring the status of running `Flink` jobs

3. **Kafka-Connect**
   * Kafka Connect JDBC Sink Connector is use to stream data from the `Kafka` topic `eonet_cleaned` into `PostgreSQL` databases.
   * Data is inserted using the upsert pattern (update existing rows when the same primary key is encountered); ensuring no duplicate PKs.

4. **PostgreSQL**
   * PostgreSQL is used for persisting the processed data; and let downstream consumer query the data (custom Mapbox back-ends).

5. **Kafka UI**
   * A web-based interface for easy monitoring of Kafka topics, producers, and consumers.

6. **Docker**
   * Overall pipeline is orchestrated via `Docker` compose; check the `./docker-compose.yml` for detailed orchestrations;

---

## **Project Setup and Execution**

### **1. Clone the Repository:**

```bash
git clone https://github.com/Creative-Ataraxia/eonet-realtime-streaming.git
cd eonet-realtime-streaming
```

### **2. Docker Setup:**

This project uses **Docker Compose** to set up the serviced required: `Kafka`, `Flink`, `PostgreSQL`, and `Kafka-Connect`.

To start the pipeline, run:

```bash
docker-compose up
```

This will spin up the following services:

* **Kafka Broker** (bitnami/kafka:4.0.0)
* **PostgreSQL** (postgres\:latest)
* **Apache Flink** (flink:2.0.0)
* **Kafka Connect** (confluentinc/cp-kafka-connect)
* **Kafka UI** (provectuslabs/kafka-ui)

Review logs for any errors or ongoing processes via Docker:

```bash
docker-compose logs -f
```

Submit an issue if you feel like it;

---

## **Pipeline Workflow**

### **3. Kafka Topic Creation**

The custom `kafka-topics-init` service automatically creates the required Kafka topics downstream (`eonet_raw`, `eonet_flattened`, `eonet_dlq`, `eonet_cleaned`) when the pipeline starts up. The topics are created using `Kafka`'s CLI: `kafka-topics.sh` via the `kafka-broker` container.

### **4. Flink Jobs**

The following `Flink` SQL jobs are responsible for processing the data:

* **eonet\_raw**: Raw data is ingested from external sources (NASA's EONET API).
* **eonet\_flattened**: Raw data is flattened, cleaned, and transformed.
* **eonet\_cleaned**: The final processed data is stored in this Kafka topic, ready for downstream consumes (JDBC Sink Connector, Postgres).

You can submit the Flink jobs from the **Flink UI** (`http://localhost:8081`) once the Docker containers are up and healthy by:
   ```bash
   docker exec -it flink-jobmanager /bin/bash
   ```
   then:
   ```bash
   ./bin/sql-client.sh -f /opt/sql/full-job.sql
   ```

### **5. Kafka Connect JDBC Sink Connector**

The **JDBC Sink Connector** is used to sink data from the Kafka topic `eonet_cleaned` to `PostgreSQL`. The configuration of this connector is done using a custom JSON config file, which is automatically registered in Kafka Connect via an HTTP request.

### **6. Access the Kafka UI**

You can access the `Kafka UI` via `http://localhost:8080` to monitor and manage Kafka brokers, topics, messages, and consumer groups.

---

## **Roadmap**

* **Error Handling**: Implement better error handling for message delivery failures between all services;
* **Scalability**: Refactor pipeline into Airflow DAGs, and deploy via k8s clusters;
* **Monitoring & Alerting**: Integrate monitoring tools (Prometheus and Grafana) to keep track of the health of the services.

## **Contact**

For questions or suggestions, feel free to reach out to me at \[roy.ma9@gmail.com].
