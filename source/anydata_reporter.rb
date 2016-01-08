require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/anytype_info.sql',
  '../../../sql/anydata_helper.pks',
  '../../../sql/anydata_helper.pkb',
  '../../../sql/anydata_helpers/anydata_base.sql',
  '../../../sql/anydata_helpers/anydata_compound.sql',
  '../../../sql/anydata_helpers/anydata_char.sql',
  '../../../sql/anydata_helpers/anydata_collection.sql',
  '../../../sql/anydata_helpers/anydata_object.sql',
  '../../../sql/anydata_reporter.pks',
  '../../../sql/anydata_reporter.pkb'
].each { |file| execute_sqlplus_file(file) }

