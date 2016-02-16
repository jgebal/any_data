require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/uninstall.sql',
  '../../../sql/helpers/string_array.sql',
  '../../../sql/helpers/any_data_formatter.pks',
  '../../../sql/helpers/any_data_formatter.pkb',
  '../../../sql/core/any_data.tps',
  '../../../sql/core/any_data_attribute.sql',
  '../../../sql/core/any_data_tab.sql',
  '../../../sql/core/any_data_compound.sql',
  '../../../sql/core/any_data_object.sql',
  '../../../sql/core/any_data_collection.sql',
  '../../../sql/core/any_data_number.sql',
  '../../../sql/core/any_data_varchar2.sql',
  '../../../sql/core/any_data_varchar.sql',
  '../../../sql/core/any_data_char.sql',
  '../../../sql/core/any_data_date.sql',
  '../../../sql/core/any_data_bdouble.sql',
  '../../../sql/core/any_data_bfloat.sql',
  '../../../sql/core/any_data_blob.sql',
  '../../../sql/core/any_data_intervalds.sql',
  '../../../sql/core/any_data_intervalym.sql',
  '../../../sql/core/any_data_clob.sql',
  '../../../sql/converter/any_type_mapper.sql',
  '../../../sql/converter/any_data_builder.pks',
  '../../../sql/converter/any_data_builder.pkb',
].each { |file| execute_sqlplus_file(file) }


