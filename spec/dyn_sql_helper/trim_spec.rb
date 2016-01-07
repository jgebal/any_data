describe 'Anydata helper trim function' do

  it 'returns a string with trim function' do
    expect( plsql.anydata_helper.trim('v_str') ).to eq "trim( v_str )"
  end

end
