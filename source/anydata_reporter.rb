require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/uninstall.sql',
  '../../../sql/anytype_info.sql',
  '../../../sql/anydata_helper.pks',
  '../../../sql/anydata_helper.pkb',
  '../../../sql/anydata_helpers/anydata_base.tps',
  '../../../sql/anydata_helpers/anydata_base_arr.tps',
  '../../../sql/anydata_helpers/anydata_char.tps',
  '../../../sql/anydata_helpers/anydata_compound.tps',
  '../../../sql/anydata_helpers/anydata_collection.tps',
  '../../../sql/anydata_helpers/anydata_object.tps',
  '../../../sql/anydata_reporter.pks',
  '../../../sql/anydata_helpers/anydata_base.tpb',
  '../../../sql/anydata_helpers/anydata_char.tpb',
  '../../../sql/anydata_helpers/anydata_compound.tpb',
  '../../../sql/anydata_helpers/anydata_collection.tpb',
  '../../../sql/anydata_helpers/anydata_object.tpb',
  '../../../sql/anydata_reporter.pkb',
].each { |file| execute_sqlplus_file(file) }

