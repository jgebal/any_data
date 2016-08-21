Dir.chdir "sources"
`sqlplus generic_util/generic_util@xe @uninstall.sql` #no output to screen
`sqlplus generic_util/generic_util@xe @install.sql`   #no output to screen
# system('sqlplus generic_util/generic_util@xe @uninstall.sql') #with output to screen
# system('sqlplus generic_util/generic_util@xe @install.sql')   #with output to screen
Dir.chdir ".."
