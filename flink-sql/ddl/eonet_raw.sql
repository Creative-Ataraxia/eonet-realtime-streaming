CREATE TABLE IF NOT EXISTS eonet_raw (
  `id` STRING,
  `title` STRING,
  `description` STRING,
  `link` STRING,
  `closed` STRING,
  `categories` ARRAY<ROW<id STRING, title STRING>>,
  `sources` ARRAY<ROW<id STRING, url STRING>>,
  `geometry` ARRAY<ROW<
    `magnitudeValue` DOUBLE,
    `magnitudeUnit` STRING,
    `date` TIMESTAMP(3),
    `type` STRING,
    `coordinates` ARRAY<DOUBLE>
  >>,
  event_time AS PROCTIME()
) WITH (
  'connector' = 'kafka',
  'topic' = 'eonet_raw',
  'properties.bootstrap.servers' = 'kafka-broker:9092',
  'format' = 'json',
  'json.ignore-parse-errors' = 'true',
  'scan.startup.mode' = 'earliest-offset',
  'properties.group.id' = 'flink-eonet-group'
);
