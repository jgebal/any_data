def any_data_method(method, type, value, other_type, other_value)
  value = value || 'NULL'
  other_value = other_value || 'NULL'
  sql = <<-SQL
      DECLARE
         result boolean;
      BEGIN
         result := #{type}( #{value} ).#{method}( #{other_type}( #{other_value} ) );
         :x := CASE WHEN result THEN 1 WHEN NOT result THEN 0 END;
      END;
  SQL
  cursor = plsql.connection.parse(sql).bind_param(":x", nil, :data_type => 'NUMBER', :in_out => 'OUT')
  cursor.exec
  result = cursor[":x"].nil? ? nil : cursor[":x"]==1
  cursor.close
  result
end

