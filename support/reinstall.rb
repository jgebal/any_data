# system('sqlplus generic_util/generic_util@xe @sql/uninstall.sql') > nil
# system('sqlplus generic_util/generic_util@xe @sql/install.sql') > nil

require_relative 'execute_sqlplus_file'

execute_sqlplus_file('../../sql/uninstall.sql')

File.open("sql/install.sql").each_line do |line|
  line.chomp!
  if line[/^\@\@/] then
    file_name = line.sub('@@','../../')
    execute_sqlplus_file(file_name)
  end
end
