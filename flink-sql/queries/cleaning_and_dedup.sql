-- Validate and route invalid records into DLQ
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

-- Deduplicate and produce cleaned dataset
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