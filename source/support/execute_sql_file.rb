def execute_sql_file(file_name)
  proftab_file = File.expand_path(file_name, __FILE__)
  File.read(proftab_file).split(";\n/\n").each do |sql|
    puts sql+';'
    if sql =~ /^drop/i
      plsql(@connection_alias).execute sql rescue nil
    elsif sql =~ /^(create|comment)/i
      plsql(@connection_alias).execute sql+';'
    end
  end
end
