package com.example.transforms;

import org.apache.kafka.common.config.ConfigDef;
import org.apache.kafka.connect.connector.ConnectRecord;
import org.apache.kafka.connect.data.Schema;
import org.apache.kafka.connect.data.SchemaBuilder;
import org.apache.kafka.connect.data.Struct;
import org.apache.kafka.connect.transforms.Transformation;

import java.util.Map;

public class WrapWithSchema<R extends ConnectRecord<R>> implements Transformation<R> {
  private Schema schema;

  @Override
  public R apply(R record) {
    // 1) skip tombstones
    if (record.value() == null) {
      return record;
    }
    @SuppressWarnings("unchecked")
    Map<String,Object> plain = (Map<String,Object>) record.value();

    // 2) lazily build the flat schema once
    if (schema == null) {
      schema = SchemaBuilder.struct().name("eonet_cleaned")
        .field("id",             Schema.STRING_SCHEMA)
        .field("title",          Schema.OPTIONAL_STRING_SCHEMA)
        .field("category_title", Schema.OPTIONAL_STRING_SCHEMA)
        .field("magnitude",      Schema.OPTIONAL_FLOAT64_SCHEMA)
        .field("magnitude_unit", Schema.OPTIONAL_STRING_SCHEMA)
        .field("geom_date",      Schema.OPTIONAL_INT64_SCHEMA)
        .field("lon",            Schema.OPTIONAL_FLOAT64_SCHEMA)
        .field("lat",            Schema.OPTIONAL_FLOAT64_SCHEMA)
        .field("processed_time", Schema.OPTIONAL_INT64_SCHEMA)
        .build();
    }

    // 3) populate the Struct
    Struct out = new Struct(schema)
      .put("id",              plain.get("id"))
      .put("title",           plain.get("title"))
      .put("category_title",  plain.get("category_title"))
      .put("magnitude",       plain.get("magnitude"))
      .put("magnitude_unit",  plain.get("magnitude_unit"))
      .put("geom_date",       plain.get("geom_date"))
      .put("lon",             plain.get("lon"))
      .put("lat",             plain.get("lat"))
      .put("processed_time",  plain.get("processed_time"));

    // 4) return a new record with that schema+Struct as the value
    return record.newRecord(
      record.topic(),
      record.kafkaPartition(),
      record.keySchema(),
      record.key(),
      schema,
      out,
      record.timestamp()
    );
  }

  @Override public ConfigDef config() { return new ConfigDef(); }
  @Override public void configure(Map<String,?> configs) { }
  @Override public void close() { }
}
