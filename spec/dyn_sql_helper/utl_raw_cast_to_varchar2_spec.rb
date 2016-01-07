describe 'Anydata helper utl_raw_cast_to_varchar2 function' do

  it 'returns a string with utl_raw_cast_to_varchar2 function' do
    expect( plsql.anydata_helper.utl_raw_cast_to_varchar2('v_raw') ).to eq "utl_raw.cast_to_varchar2( v_raw )"
  end

end
