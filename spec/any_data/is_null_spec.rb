describe 'any data is_null comparison' do

  def any_data_is_null( type, value )
    value = value || 'NULL'
    sql = <<-SQL
      DECLARE
         result boolean;
      BEGIN
         result := #{type}( #{value} ).is_null();
         :x := CASE WHEN result THEN 1 WHEN NOT result THEN 0 END;
      END;
    SQL
    cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'NUMBER', :in_out => 'OUT')
    cursor.exec
    result = cursor[":x"].nil? ? nil : cursor[":x"]==1
    cursor.close
    result
  end

  it 'returns true when any_data value is NULL' do
    expect( any_data_is_null( 'any_data_number', NULL ) ).to eq true
  end

  it 'returns false when any_data value is not NULL' do
    expect( any_data_is_null( 'any_data_number', 1 ) ).to eq false
  end

end

