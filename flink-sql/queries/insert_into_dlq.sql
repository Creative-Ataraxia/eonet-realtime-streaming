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