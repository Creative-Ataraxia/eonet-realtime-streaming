CREATE TABLE eonet_raw (id STRING, payload STRING) WITH (
    'connector' = 'kafka',
    'topic' = 'eonet_raw',
    'properties.bootstrap.servers' = 'kafka-broker:9092',
    'format' = 'json',
    'scan.startup.mode' = 'earliest-offset'
);

CREATE TABLE eonet_test (id STRING, payload STRING, processed_by_flink BOOLEAN) WITH (
    'connector' = 'kafka',
    'topic' = 'eonet_test',
    'properties.bootstrap.servers' = 'kafka-broker:9092',
    'format' = 'json'
);