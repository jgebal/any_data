describe 'Anydata helper to_char function' do

  it 'returns a string with to_char function and a format' do
    expect( plsql.anydata_helper.to_char('v_date','yyyy-mm-dd') ).to eq "to_char( v_date, 'yyyy-mm-dd' )"
  end

  it 'returns a string with to_char function and no format' do
    expect( plsql.anydata_helper.to_char('v_number') ).to eq "to_char( v_number )"
  end
end
