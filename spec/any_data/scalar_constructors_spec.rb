shared_examples 'any data constructor for scalar types' do |params|

  object_type = params[:self_type_name].to_sym
  expected    = params

  it 'creates instance of object using full constructor' do
    result = plsql.send(object_type, expected)
    expect(result).to eq(expected)
  end

  it 'creates instance of object using data value only' do
    result = plsql.plsql.send(object_type, expected[:data_value])
    expect(result).to eq(expected)
  end

end

[
  # Disabled as ruby-plsql 0.5.3 does not support binary_double and binary_float
  # { type_code: plsql.dbms_types.typecode_bdouble,  type_name: 'BINARY_DOUBLE', self_type_name: 'any_data_bdouble',  data_value: 123.456789 },
  # { type_code: plsql.dbms_types.typecode_bfloat,   type_name: 'BINARY_FLOAT',  self_type_name: 'any_data_bfloat',   data_value: 123.125 },
  { type_code: plsql.dbms_types.typecode_number,   type_name: 'NUMBER',        self_type_name: 'any_data_number',   data_value: 3 },
  { type_code: plsql.dbms_types.typecode_blob,     type_name: 'BLOB',          self_type_name: 'any_data_blob',     data_value: '1234%$#$%DRGSDFG$#%' },
  { type_code: plsql.dbms_types.typecode_raw,      type_name: 'RAW',           self_type_name: 'any_data_raw',      data_value: '1234%$#$%DRGSDFG$#%' },
  { type_code: plsql.dbms_types.typecode_char,     type_name: 'CHAR',          self_type_name: 'any_data_char',     data_value: 'A' },
  { type_code: plsql.dbms_types.typecode_varchar,  type_name: 'VARCHAR',       self_type_name: 'any_data_varchar',  data_value: 'Sample varchar' },
  { type_code: plsql.dbms_types.typecode_varchar2, type_name: 'VARCHAR2',      self_type_name: 'any_data_varchar2', data_value: 'Sample varchar2' },
  { type_code: plsql.dbms_types.typecode_clob,     type_name: 'CLOB',          self_type_name: 'any_data_clob',     data_value: 'clob value' },
  { type_code: plsql.dbms_types.typecode_date,     type_name: 'DATE',          self_type_name: 'any_data_date',     data_value: Time.today },
].each do |element|

  describe element[:self_type_name] do
    include_examples 'any data constructor for scalar types', element
  end

end
