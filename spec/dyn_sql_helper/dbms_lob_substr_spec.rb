describe 'Dynamic SQL helper substr function' do

  it 'returns a string with dbms_lob_substr function and len, start parameters' do
    expect( plsql.dyn_sql_helper.dbms_lob_substr('v_str',100, 1) ).to eq "dbms_lob.substr( v_str, 100, 1 )"
  end

  it 'returns a string with dbms_lob_substr function with len parameter' do
    expect( plsql.dyn_sql_helper.dbms_lob_substr('v_str',100) ).to eq "dbms_lob.substr( v_str, 100 )"
  end
end
