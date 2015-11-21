require 'anydata_reporter'

describe 'anydata reporter' do

  def exec_reporter(reporter_call)
    sql =  <<-SQL
      BEGIN
        :x := #{reporter_call}
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'VARCHAR2', :in_out => 'OUT')
    cursor.exec
    cursor[":x"]
  end

  it 'reports a simple numeric' do
    result = exec_reporter <<-SQL
      anydata_reporter('pv_numeric', ANYDATA.ConvertNumber(3)).get_report;
    SQL
    expect( result ).to eq 'pv_numeric(NUMBER)=>3'
  end

end
