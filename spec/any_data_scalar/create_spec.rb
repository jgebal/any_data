describe 'any_data construct' do

  it 'creates instance of object using full constructor' do
    expected = { type_code: plsql.dbms_types.typecode_number, type_name: 'NUMBER', data_value: 12345 }
    result = plsql.any_data_number( expected )
    expect( result ).to eq( expected )
  end

  it 'creates instance of object using simple constructor' do
    expected = { type_code: plsql.dbms_types.typecode_number, type_name: 'NUMBER', data_value: 12345 }
    result = plsql.any_data_number(12345)
    expect( result ).to eq( expected )
  end

  it 'creates instance of object using full constructor' do
    expected = { type_code: plsql.dbms_types.typecode_bdouble, type_name: 'BINARY_DOUBLE', data_value: 12345 }
    puts plsql.any_data_bdouble.attributes
    result = plsql.any_data_bdouble( expected )
    expect( result ).to eq( expected )
  end

  it 'creates instance of object using simple constructor' do
    expected = { type_code: plsql.dbms_types.typecode_bdouble, type_name: 'BINARY_DOUBLE', data_value: 12345 }
    result = plsql.any_data_bdouble(12345)
    expect( result ).to eq( expected )
  end
end
