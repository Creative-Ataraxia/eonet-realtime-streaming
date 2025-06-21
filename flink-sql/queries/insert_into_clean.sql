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