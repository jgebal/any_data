describe 'Anydata helper substr function' do

  it 'returns a string with substr function and start, len parameters' do
    expect( plsql.anydata_helper.substr('v_str',1,100) ).to eq "substr( v_str, 1, 100 )"
  end

  it 'returns a string with substr function with start parameter' do
    expect( plsql.anydata_helper.substr('v_str',1) ).to eq "substr( v_str, 1 )"
  end
end
