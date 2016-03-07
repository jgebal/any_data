def execute_sqlplus_file(file_name)
  full_file_path = File.expand_path(file_name, __FILE__)
  File.read(full_file_path).split(";\n/\n").each do |sql|
    # puts sql+';'
    if sql =~ /^drop/i
      plsql(@connection_alias).execute sql rescue nil
    elsif sql =~ /^(create|comment)/i
      plsql(@connection_alias).execute sql+';'
    end
  end
end
