INSERT INTO eonet_test
SELECT id, payload, TRUE as processed_by_flink
FROM eonet_raw;