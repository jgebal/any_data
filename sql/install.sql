@@./VERSION.sql
set verify off
prompt installing any_data library VERSION &&VERSION
alter session set plsql_optimize_level = 3;
@@sql/helpers/string_array.sql
@@sql/helpers/any_data_const.pks
@@sql/helpers/any_data_formatter.pks
@@sql/helpers/any_data_formatter.pkb
@@sql/helpers/any_data_typecode_mapper.pks
@@sql/helpers/any_data_typecode_mapper.pkb

@@sql/core/any_data.sql
@@sql/core/any_data_attribute.sql
@@sql/core/any_data_tab.sql

@@sql/core/any_data_family_compound.sql
@@sql/core/any_data_object.sql
@@sql/core/any_data_collection.sql

@@sql/core/any_data_family_numeric.sql
@@sql/core/any_data_number.sql

@@sql/core/any_data_family_string.sql
@@sql/core/any_data_varchar2.sql
@@sql/core/any_data_varchar.sql
@@sql/core/any_data_char.sql
@@sql/core/any_data_clob.sql

@@sql/core/any_data_bdouble.sql
@@sql/core/any_data_bfloat.sql

@@sql/core/any_data_family_raw.sql
@@sql/core/any_data_raw.sql
@@sql/core/any_data_blob.sql

@@sql/core/any_data_family_date.sql
@@sql/core/any_data_date.sql
@@sql/core/any_data_timestamp.sql
@@sql/core/any_data_timestamp_tz.sql
@@sql/core/any_data_timestamp_ltz.sql

@@sql/core/any_data_interval_ds.sql
@@sql/core/any_data_interval_ym.sql


@@sql/converter/type_code_mappings.sql

@@sql/converter/any_type_mapper.sql

@@sql/converter/any_data_builder.pks
@@sql/converter/any_data_builder.pkb

exit
