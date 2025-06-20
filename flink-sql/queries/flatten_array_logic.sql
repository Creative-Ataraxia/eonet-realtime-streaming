INSERT INTO eonet_flattened
SELECT
  `id`,
  `title`,
  `categories`[1].`id` AS category_id,
  `categories`[1].`title` AS category_title,

  -- Access last(and newest) element of geometry array directly
  geometry_elem.magnitudeValue AS magnitude,
  geometry_elem.magnitudeUnit AS magnitude_unit,
  geometry_elem.`date` AS geom_date,
  geometry_elem.coordinates[1] AS lon,
  geometry_elem.coordinates[2] AS lat

FROM (
  SELECT
    `id`,
    `title`,
    `categories`,
    -- Pull out last element
    geometry[cardinality(geometry)] AS geometry_elem
  FROM `eonet_raw`
);
