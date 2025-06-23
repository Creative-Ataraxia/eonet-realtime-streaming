CREATE TABLE IF NOT EXISTS eonet_cleaned (
    id TEXT PRIMARY KEY,
    title TEXT,
    category_title TEXT,
    magnitude DOUBLE PRECISION,
    magnitude_unit TEXT,
    geom_date TIMESTAMP,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    processed_time TIMESTAMP
);

CREATE TABLE IF NOT EXISTS eonet_test (
    id TEXT PRIMARY KEY,
    title TEXT,
    category_title TEXT,
    magnitude DOUBLE PRECISION,
    magnitude_unit TEXT,
    geom_date TIMESTAMP,
    lon DOUBLE PRECISION,
    lat DOUBLE PRECISION,
    processed_time TIMESTAMP
);