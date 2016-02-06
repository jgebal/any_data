require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/uninstall.sql',
  '../../../sql/helpers/any_data_formatter.pks',
  '../../../sql/helpers/any_data_formatter.pkb',
  '../../../sql/core/any_type.sql',
  '../../../sql/core/any_data.tps',
  '../../../sql/core/any_data_attribute.sql',
  '../../../sql/core/any_data_tab.sql',
  '../../../sql/core/any_data_compound.sql',
  '../../../sql/core/any_data_object.sql',
  '../../../sql/core/any_data_collection.sql',
  '../../../sql/core/any_data_number.sql',
  '../../../sql/converter/any_type_mapper.sql',
  '../../../sql/converter/any_data_builder.pks',
  '../../../sql/converter/any_data_builder.pkb',
].each { |file| execute_sqlplus_file(file) }


