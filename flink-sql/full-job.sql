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
    `date` STRING, -- cast as string here for the later replace to timestamp hack
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
  'sink.transactional-id-prefix' = 'raw-job-',
  'properties.group.id' = 'flink-eonet-group'
);


CREATE TABLE IF NOT EXISTS eonet_flattened (
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
  'topic' = 'eonet_flattened',
  'properties.bootstrap.servers' = 'kafka-broker:9092',
  'key.format' = 'json',
  'value.format' = 'json',
  'sink.transactional-id-prefix' = 'flattened-job-',
  'properties.group.id' = 'flink-eonet-group'
);


INSERT INTO eonet_flattened
SELECT
  `id`,
  `title`,
  `categories`[1].`id` AS category_id,
  `categories`[1].`title` AS category_title,

  -- Access last (and newest) element directly
  geometry_elem.magnitudeValue AS magnitude,
  geometry_elem.magnitudeUnit AS magnitude_unit,

  TO_TIMESTAMP(
    REPLACE(REPLACE(geometry_elem.`date`, 'T', ' '), 'Z', ''), -- use this replace pattern to manually cast to timestep, because setting to ISO-8601 didn't work
    'yyyy-MM-dd HH:mm:ss'
  ) AS geom_date,

  geometry_elem.coordinates[1] AS lon,
  geometry_elem.coordinates[2] AS lat

FROM (
  SELECT
    `id`,
    `title`,
    `categories`,
    geometry[cardinality(geometry)] AS geometry_elem
  FROM eonet_raw
);


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
  'sink.transactional-id-prefix' = 'dlq-job-',
  'properties.group.id' = 'flink-eonet-group'
);


INSERT INTO eonet_dlq
SELECT
  id,
  title,
  category_id,
  category_title,
  magnitude,
  magnitude_unit,
  geom_date,
  lon,
  lat
FROM eonet_flattened
WHERE id IS NULL
   OR title IS NULL
   OR category_title IS NULL
   OR geom_date IS NULL
   OR lon IS NULL
   OR lat IS NULL;


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
  'sink.transactional-id-prefix' = 'cleaned-job-',
  'properties.group.id' = 'flink-eonet-group'
);


INSERT INTO eonet_cleaned
SELECT
  id,
  title,
  category_title,
  geom_date,
  lon,
  lat,
  CURRENT_TIMESTAMP AS processed_time
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY id ORDER BY geom_date DESC) AS rownum
  FROM eonet_flattened
  WHERE id IS NOT NULL
    AND title IS NOT NULL
    AND category_title IS NOT NULL
    AND geom_date IS NOT NULL
    AND lon IS NOT NULL
    AND lat IS NOT NULL
)
WHERE rownum = 1;
