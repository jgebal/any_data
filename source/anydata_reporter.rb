require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/anytype_info.sql',
  '../../../sql/dyn_sql_helper.pks',
  '../../../sql/dyn_sql_helper.pkb',
  '../../../sql/anydata_helpers/anydata_helper_base.sql',
  '../../../sql/anydata_helpers/anydata_helper_number.sql',
  '../../../sql/anydata_helpers/anydata_helper_char.sql',
  '../../../sql/anydata_helpers/anydata_helper_timestamp.sql',
  '../../../sql/anydata_helpers/anydata_helper_clob.sql',
  '../../../sql/anydata_helpers/anydata_helper_collection.sql',
  '../../../sql/anydata_helpers/anydata_helper_nchar.sql',
  '../../../sql/anydata_helpers/anydata_helper_varchar2.sql',
  '../../../sql/anydata_helpers/anydata_helper_cfile.sql',
  '../../../sql/anydata_helpers/anydata_helper_varchar.sql',
  '../../../sql/anydata_helpers/anydata_helper_bfloat.sql',
  '../../../sql/anydata_helpers/anydata_helper_date.sql',
  '../../../sql/anydata_helpers/anydata_helper_interval_ds.sql',
  '../../../sql/anydata_helpers/anydata_helper_object.sql',
  '../../../sql/anydata_helpers/anydata_helper_blob.sql',
  '../../../sql/anydata_helpers/anydata_helper_timestamp_tz.sql',
  '../../../sql/anydata_helpers/anydata_helper_nvarchar2.sql',
  '../../../sql/anydata_helpers/anydata_helper_interval_ym.sql',
  '../../../sql/anydata_helpers/anydata_helper_nclob.sql',
  '../../../sql/anydata_helpers/anydata_helper_timestamp_ltz.sql',
  '../../../sql/anydata_helpers/anydata_helper_bdouble.sql',
  '../../../sql/anydata_helpers/anydata_helper_bfile.sql',
  '../../../sql/anydata_helpers/anydata_helper_raw.sql',
  '../../../sql/anydata_reporter.pks',
  '../../../sql/anydata_reporter.pkb'
].each { |file| execute_sqlplus_file(file) }

