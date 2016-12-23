
shared_examples 'any data constructor for scalar types' do |params|

  object_type = params[:self_type_name].to_sym
  expected    = params.merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})

  it 'creates instance of object using full constructor' do
    result = plsql.send(object_type, expected)
    expect(result.merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})).to eq(expected)
  end

  it 'creates instance of object using data value only' do
    result = plsql.send(object_type, expected[:data_value])
    expect(result.merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})).to eq(expected)
  end

end
describe 'any_data construction' do
  [
    # Disabled as ruby-plsql 0.5.3 does not support binary_double, binary_float and interval datatypes
    # { type_code: plsql.dbms_types.typecode_bdouble,  type_name: 'BINARY_DOUBLE', self_type_name: 'any_data_bdouble',  data_value: 123.456789 },
    # { type_code: plsql.dbms_types.typecode_bfloat,   type_name: 'BINARY_FLOAT',  self_type_name: 'any_data_bfloat',   data_value: 123.125 },
    # { type_code: plsql.dbms_types.typecode_interval_ds,  type_name: 'INTERVAL DAY TO SECOND', self_type_name: 'any_data_interval_ds',  data_value: '12345:23:59:59.123456789' },
    # { type_code: plsql.dbms_types.typecode_interval_ym,  type_name: 'INTERVAL YEAR TO MONTH', self_type_name: 'any_data_interval_ym',  data_value: '12345-12' },
    # RAW type is not fully supported in ruby-plsql
    # { type_code: plsql.dbms_types.typecode_raw,      type_name: 'RAW',           self_type_name: 'any_data_raw',       data_value: "01AB" },
    { type_code: plsql.dbms_types.typecode_number,     type_name: 'NUMBER',        self_type_name: 'ANY_DATA_NUMBER',    data_value: 3 },
    { type_code: plsql.dbms_types.typecode_blob,       type_name: 'BLOB',          self_type_name: 'ANY_DATA_BLOB',      data_value: "O1AA" },
    { type_code: plsql.dbms_types.typecode_char,       type_name: 'CHAR',          self_type_name: 'ANY_DATA_CHAR',      data_value: 'A' },
    { type_code: plsql.dbms_types.typecode_varchar,    type_name: 'VARCHAR',       self_type_name: 'ANY_DATA_VARCHAR',   data_value: 'Sample varchar' },
    { type_code: plsql.dbms_types.typecode_varchar2,   type_name: 'VARCHAR2',      self_type_name: 'ANY_DATA_VARCHAR2',  data_value: 'Sample varchar2' },
    { type_code: plsql.dbms_types.typecode_clob,       type_name: 'CLOB',          self_type_name: 'ANY_DATA_CLOB',      data_value: 'clob ''value' },
    { type_code: plsql.dbms_types.typecode_date,       type_name: 'DATE',          self_type_name: 'ANY_DATA_DATE',      data_value: Time.today },
    # { type_code: 187,                                  type_name: 'TIMESTAMP',     self_type_name: 'any_data_timestamp', data_value: Time.now },
  ].each do |element|

    describe element[:self_type_name] do
      include_examples 'any data constructor for scalar types', element
    end

  end

  describe 'any_data_collection' do

    it 'creates instance of object using full constructor' do
      expected ={
        type_code: plsql.dbms_types.typecode_namedcollection,
        type_name: 'collection',
        self_type_name: 'ANY_DATA_COLLECTION',
        data_values: plsql.any_data_tab( NULL )
      }

      expect(
        plsql.any_data_collection( expected ).merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})
      ).to eq(expected.merge({type_hash: NULL, value_hash: NULL, name_hash: NULL}))
    end

    it 'creates instance of object using data values and type name' do
      expected ={
        type_code: 248, #typecode_table
        type_name: 'SOME_COLLECTION',
        self_type_name: 'ANY_DATA_COLLECTION',
        data_values: plsql.any_data_tab( NULL )
      }

      expect(
        plsql.any_data_collection( expected[:type_name], expected[:data_values]  ).merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})
      ).to eq(expected.merge({type_hash: NULL, value_hash: NULL, name_hash: NULL}))
    end

  end

  describe 'any_data_object' do

    it 'creates instance of object using full constructor' do
      expected ={
        type_code: plsql.dbms_types.typecode_object,
        type_name: 'object',
        self_type_name: 'ANY_DATA_OBJECT',
        data_values: plsql.any_data_tab( NULL )
      }

      expect(
        plsql.any_data_object( expected ).merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})
      ).to eq(expected.merge({type_hash: NULL, value_hash: NULL, name_hash: NULL}))
    end

    it 'creates instance of object using data values and type name' do
      expected ={
        type_code: plsql.dbms_types.typecode_object,
        type_name: 'an_object',
        self_type_name: 'ANY_DATA_OBJECT',
        data_values: plsql.any_data_tab( NULL )
      }

      expect(
        plsql.any_data_object( expected[:type_name], expected[:data_values]  ).merge({type_hash: NULL, value_hash: NULL, name_hash: NULL})
      ).to eq(expected)
    end

  end
end
