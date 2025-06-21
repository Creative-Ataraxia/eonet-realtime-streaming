CREATE TABLE IF NOT EXISTS eonet_cleaned (
  id STRING,
  title STRING,
  category_title STRING,
  geom_date TIMESTAMP(3),
  lon DOUBLE,
  lat DOUBLE,
  processed_time TIMESTAMP(3),
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'upsert-kafka',
  'topic' = 'eonet_cleaned',
  'properties.bootstrap.servers' = 'kafka-broker:9092',
  'key.format' = 'json',
  'value.format' = 'json',
  'properties.group.id' = 'flink-eonet-group'
);