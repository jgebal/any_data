shared_examples 'any_data' do |params|

  any_type_name = params.delete(:any_type_name).to_sym
  expected      = params
  puts any_type_name
  puts params
  it 'creates instance of object using full constructor' do
    result = plsql.send(any_type_name, expected)
    expect(result).to eq(expected)
  end

  it 'creates instance of object using data value only' do
    result = plsql.plsql.send(any_type_name, expected[:data_value])
    expect(result).to eq(expected)
  end

end

[
  { any_type_name: 'any_data_bdouble', type_code: plsql.dbms_types.typecode_bdouble, type_name: 'BINARY_DOUBLE', data_value: 123.456789 },
  { any_type_name: 'any_data_bfloat', type_code: plsql.dbms_types.typecode_bfloat, type_name: 'BINARY_FLOAT', data_value: 123.125 },
  { any_type_name: 'any_data_blob', type_code: plsql.dbms_types.typecode_blob, type_name: 'BLOB', data_value: '1234%$#$%DRGSDFG$#%' },
  { any_type_name: 'any_data_clob', type_code: plsql.dbms_types.typecode_clob, type_name: 'CLOB', data_value: 'clob value' },
  { any_type_name: 'any_data_char', type_code: plsql.dbms_types.typecode_char, type_name: 'CHAR', data_value: 'A' },
  { any_type_name: 'any_data_date', type_code: plsql.dbms_types.typecode_date, type_name: 'DATE', data_value: Time.today },
  { any_type_name: 'any_data_number', type_code: plsql.dbms_types.typecode_number, type_name: 'INTEGER', data_value: 1 },
  #  not supported by ruby-plsql
  # { any_type_name: 'any_data_intervalds', type_code: plsql.dbms_types.typecode_interval_ds, type_name: 'INTERVAL DAY TO SECOND', data_value: 123456789.123456789 },
  # { any_type_name: 'any_data_intervalym', type_code: plsql.dbms_types.typecode_interval_ym, type_name: 'INTERVAL YEAR TO MONTH', data_value: 11 },
  { any_type_name: 'any_data_number', type_code: plsql.dbms_types.typecode_number, type_name: 'NUMBER', data_value: 3 },
  { any_type_name: 'any_data_varchar', type_code: plsql.dbms_types.typecode_varchar, type_name: 'VARCHAR', data_value: 'Sample varchar' },
  { any_type_name: 'any_data_varchar2', type_code: plsql.dbms_types.typecode_varchar2, type_name: 'VARCHAR2', data_value: 'Sample varchar2' },
].each do |element|

  describe element[:any_type_name] do
    include_examples 'any_data', element
  end

end
