CREATE TABLE IF NOT EXISTS eonet_flattened (
  id STRING,
  title STRING,
  category_id STRING,
  category_title STRING,
  magnitude DOUBLE,
  magnitude_unit STRING,
  geom_date TIMESTAMP(3),
  lon DOUBLE,
  lat DOUBLE
) WITH (
  'connector' = 'kafka',
  'topic' = 'eonet_flattened',
  'properties.bootstrap.servers' = 'kafka-broker:9092',
  'format' = 'json',
  'properties.group.id' = 'flink-eonet-group'
);
