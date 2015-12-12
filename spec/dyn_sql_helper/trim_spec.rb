describe 'Dynamic SQL helper trim function' do

  it 'returns a string with trim function' do
    expect( plsql.dyn_sql_helper.trim('v_str') ).to eq "trim( v_str )"
  end

end
