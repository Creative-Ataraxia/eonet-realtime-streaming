CREATE TABLE IF NOT EXISTS eonet_dlq (
  id STRING,
  title STRING,
  category_id STRING,
  category_title STRING,
  magnitude DOUBLE,
  magnitude_unit STRING,
  geom_date TIMESTAMP(3),
  lon DOUBLE,
  lat DOUBLE,
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'upsert-kafka',
  'topic' = 'eonet_dlq',
  'properties.bootstrap.servers' = 'kafka-broker:9092',
  'key.format' = 'json',
  'value.format' = 'json',
  'properties.group.id' = 'flink-eonet-group'
);