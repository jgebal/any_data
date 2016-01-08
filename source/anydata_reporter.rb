require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/anytype_info.sql',
  '../../../sql/anydata_helper.pks',
  '../../../sql/anydata_helper.pkb',
  '../../../sql/anydata_helpers/anydata_base.sql',
  '../../../sql/anydata_helpers/anydata_compound.sql',
  '../../../sql/anydata_helpers/anydata_number.sql',
  '../../../sql/anydata_helpers/anydata_char.sql',
  '../../../sql/anydata_helpers/anydata_timestamp.sql',
  '../../../sql/anydata_helpers/anydata_clob.sql',
  '../../../sql/anydata_helpers/anydata_collection.sql',
  '../../../sql/anydata_helpers/anydata_nchar.sql',
  '../../../sql/anydata_helpers/anydata_varchar2.sql',
  '../../../sql/anydata_helpers/anydata_cfile.sql',
  '../../../sql/anydata_helpers/anydata_varchar.sql',
  '../../../sql/anydata_helpers/anydata_bfloat.sql',
  '../../../sql/anydata_helpers/anydata_date.sql',
  '../../../sql/anydata_helpers/anydata_interval_ds.sql',
  '../../../sql/anydata_helpers/anydata_object.sql',
  '../../../sql/anydata_helpers/anydata_blob.sql',
  '../../../sql/anydata_helpers/anydata_timestamp_tz.sql',
  '../../../sql/anydata_helpers/anydata_nvarchar2.sql',
  '../../../sql/anydata_helpers/anydata_interval_ym.sql',
  '../../../sql/anydata_helpers/anydata_nclob.sql',
  '../../../sql/anydata_helpers/anydata_timestamp_ltz.sql',
  '../../../sql/anydata_helpers/anydata_bdouble.sql',
  '../../../sql/anydata_helpers/anydata_bfile.sql',
  '../../../sql/anydata_helpers/anydata_raw.sql',
  '../../../sql/anydata_reporter.pks',
  '../../../sql/anydata_reporter.pkb'
].each { |file| execute_sqlplus_file(file) }

