@@./../VERSION.sql
set verify off
prompt installing any_data library VERSION &&VERSION
alter session set plsql_optimize_level = 3;

@@helpers/string_array.tps
@@helpers/any_data_const.pks
@@helpers/any_data_formatter.pks
@@helpers/any_data_formatter.pkb

@@core/any_data.tps
@@core/any_data.tpb
@@core/any_data_tab.tps
@@core/compound/any_data_attribute.tps
@@core/compound/any_data_attribute.tpb

@@core/compound/any_data_family_compound.tps
@@core/compound/any_data_object.tps
@@core/compound/any_data_collection.tps
@@core/compound/any_data_result_row.tps
@@core/compound/any_data_result_set.tps

@@core/compound/any_data_family_compound.tpb
@@core/compound/any_data_object.tpb
@@core/compound/any_data_collection.tpb
@@core/compound/any_data_result_row.tpb
@@core/compound/any_data_result_set.tpb

@@core/numeric/any_data_family_numeric.tps
@@core/numeric/any_data_number.tps
@@core/numeric/any_data_bdouble.tps
@@core/numeric/any_data_bfloat.tps

@@core/numeric/any_data_family_numeric.tpb
@@core/numeric/any_data_number.tpb
@@core/numeric/any_data_bdouble.tpb
@@core/numeric/any_data_bfloat.tpb

@@core/string/any_data_family_string.tps
@@core/string/any_data_varchar2.tps
@@core/string/any_data_varchar.tps
@@core/string/any_data_char.tps
@@core/string/any_data_clob.tps

@@core/string/any_data_family_string.tpb
@@core/string/any_data_varchar2.tpb
@@core/string/any_data_varchar.tpb
@@core/string/any_data_char.tpb
@@core/string/any_data_clob.tpb

@@core/raw/any_data_family_raw.tps
@@core/raw/any_data_raw.tps
@@core/raw/any_data_blob.tps

@@core/raw/any_data_family_raw.tpb
@@core/raw/any_data_raw.tpb
@@core/raw/any_data_blob.tpb

@@core/date/any_data_family_date.tps
@@core/date/any_data_date.tps
@@core/date/any_data_timestamp.tps
@@core/date/any_data_timestamp_tz.tps
@@core/date/any_data_timestamp_ltz.tps

@@core/date/any_data_family_date.tpb
@@core/date/any_data_date.tpb
@@core/date/any_data_timestamp.tpb
@@core/date/any_data_timestamp_tz.tpb
@@core/date/any_data_timestamp_ltz.tpb

@@core/any_data_interval_ds.tps
@@core/any_data_interval_ym.tps

@@core/any_data_interval_ds.tpb
@@core/any_data_interval_ym.tpb


@@converter/dbms_type_code_mappings.sql
@@converter/sql_type_code_mappings.sql

@@converter/any_data_typecode_mapper.pks
@@converter/any_data_typecode_mapper.pkb

@@converter/any_type_mapper.tps
@@converter/any_type_mapper.tpb

@@converter/any_data_builder.pks
@@converter/any_data_builder.pkb

@@converter/populate.dbms_type_code_mappings.sql
@@converter/populate.sql_type_code_mappings.sql
exit
