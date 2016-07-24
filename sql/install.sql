@@./VERSION.sql
set verify off
prompt installing any_data library VERSION &&VERSION
alter session set plsql_optimize_level = 3;

@@sql/helpers/string_array.tps
@@sql/helpers/any_data_const.pks
@@sql/helpers/any_data_formatter.pks
@@sql/helpers/any_data_formatter.pkb

@@sql/core/any_data.tps
@@sql/core/any_data.tpb
@@sql/core/any_data_tab.tps
@@sql/core/compound/any_data_attribute.tps
@@sql/core/compound/any_data_attribute.tpb

@@sql/core/compound/any_data_family_compound.tps
@@sql/core/compound/any_data_object.tps
@@sql/core/compound/any_data_collection.tps
@@sql/core/compound/any_data_result_row.tps
@@sql/core/compound/any_data_result_set.tps

@@sql/core/compound/any_data_family_compound.tpb
@@sql/core/compound/any_data_object.tpb
@@sql/core/compound/any_data_collection.tpb
@@sql/core/compound/any_data_result_row.tpb
@@sql/core/compound/any_data_result_set.tpb

@@sql/core/numeric/any_data_family_numeric.tps
@@sql/core/numeric/any_data_number.tps
@@sql/core/numeric/any_data_bdouble.tps
@@sql/core/numeric/any_data_bfloat.tps

@@sql/core/numeric/any_data_family_numeric.tpb
@@sql/core/numeric/any_data_number.tpb
@@sql/core/numeric/any_data_bdouble.tpb
@@sql/core/numeric/any_data_bfloat.tpb

@@sql/core/string/any_data_family_string.tps
@@sql/core/string/any_data_varchar2.tps
@@sql/core/string/any_data_varchar.tps
@@sql/core/string/any_data_char.tps
@@sql/core/string/any_data_clob.tps

@@sql/core/string/any_data_family_string.tpb
@@sql/core/string/any_data_varchar2.tpb
@@sql/core/string/any_data_varchar.tpb
@@sql/core/string/any_data_char.tpb
@@sql/core/string/any_data_clob.tpb

@@sql/core/raw/any_data_family_raw.tps
@@sql/core/raw/any_data_raw.tps
@@sql/core/raw/any_data_blob.tps

@@sql/core/raw/any_data_family_raw.tpb
@@sql/core/raw/any_data_raw.tpb
@@sql/core/raw/any_data_blob.tpb

@@sql/core/date/any_data_family_date.tps
@@sql/core/date/any_data_date.tps
@@sql/core/date/any_data_timestamp.tps
@@sql/core/date/any_data_timestamp_tz.tps
@@sql/core/date/any_data_timestamp_ltz.tps

@@sql/core/date/any_data_family_date.tpb
@@sql/core/date/any_data_date.tpb
@@sql/core/date/any_data_timestamp.tpb
@@sql/core/date/any_data_timestamp_tz.tpb
@@sql/core/date/any_data_timestamp_ltz.tpb

@@sql/core/any_data_interval_ds.tps
@@sql/core/any_data_interval_ym.tps

@@sql/core/any_data_interval_ds.tpb
@@sql/core/any_data_interval_ym.tpb


@@sql/converter/dbms_type_code_mappings.sql
@@sql/converter/sql_type_code_mappings.sql

@@sql/converter/any_data_typecode_mapper.pks
@@sql/converter/any_data_typecode_mapper.pkb

@@sql/converter/any_type_mapper.tps
@@sql/converter/any_type_mapper.tpb

@@sql/converter/any_data_builder.pks
@@sql/converter/any_data_builder.pkb

@@sql/converter/populate.dbms_type_code_mappings.sql
@@sql/converter/populate.sql_type_code_mappings.sql
exit
