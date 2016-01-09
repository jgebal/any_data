require "rubygems"
require "ruby-plsql-spec"
require "yaml"
require 'erb'

def get_connections_hash( connections_file )
  database_config = YAML::load( ERB.new(IO.read(connections_file)).result )
  database_config = {} unless database_config.is_a?(Hash)
  database_config
end

def connect_all( connections_hash )
  connections_hash.each do |name, params|
    # change all keys to symbols
    name = name.to_sym
    symbol_params = Hash[*params.map{|k,v| [k.to_sym, v]}.flatten]

    plsql(name).connect! symbol_params

    # Set autocommit to false so that automatic commits after each statement are _not_ performed
    plsql(name).connection.autocommit = false
    # reduce network traffic in case of large resultsets
    plsql(name).connection.prefetch_rows = 100
    # log DBMS_OUTPUT to standard output
    # if ENV['PLSQL_DBMS_OUTPUT']
    plsql(name).dbms_output_stream = STDOUT
    # end

    # start code coverage collection
    if ENV['PLSQL_COVERAGE']
      PLSQL::Coverage.start(name)
    end
  end
  connections_hash.keys.map{|k| k.to_sym}
end

def disconnect_all( connection_names )
  connection_names.each do |name|
    if ENV['PLSQL_COVERAGE']
      PLSQL::Coverage.stop(name)
      coverage_directory = name == :default ? ENV['PLSQL_COVERAGE'] : "#{ENV['PLSQL_COVERAGE']}/#{name}"
      options = {:directory => coverage_directory}
      options[:ignore_schemas] = ENV['PLSQL_COVERAGE_IGNORE_SCHEMAS'].split(',') if ENV['PLSQL_COVERAGE_IGNORE_SCHEMAS']
      options[:like] = ENV['PLSQL_COVERAGE_LIKE'].split(',') if ENV['PLSQL_COVERAGE_LIKE']
      PLSQL::Coverage.report name, options
      PLSQL::Coverage.cleanup name
    end
    plsql(name).logoff
  end

end

connections_hash = get_connections_hash(File.expand_path('../database.yml', __FILE__))

# create all connections specified in database.yml file
connection_names = connect_all( connections_hash )

# Do logoff when exiting to ensure that session temporary tables
# (used when calling procedures with table types defined in packages)
at_exit{ disconnect_all( connection_names ) }

RSpec.configure do |config|
  config.before(:each) do
    connection_names.each do |name|
      plsql(name).savepoint "before_each" unless plsql(name).connection.autocommit?
    end
  end
  config.after(:each) do
    # Always perform rollback to savepoint after each test
    connection_names.each do |name|
      plsql(name).rollback_to "before_each" unless plsql(name).connection.autocommit?
    end
  end
  config.after(:all) do
    # Always perform rollback after each describe block
    connection_names.each do |name|
      plsql(name).rollback unless plsql(name).connection.autocommit?
    end
  end
end

# require all helper methods which are located in any helpers subdirectories
Dir[File.dirname(__FILE__) + '/**/helpers/*.rb'].each {|f| require f}

# require all factory modules which are located in any factories subdirectories
Dir[File.dirname(__FILE__) + '/**/factories/*.rb'].each {|f| require f}

# If necessary add source directory to load path where PL/SQL procedures are defined.
# It is not required if PL/SQL procedures are already loaded in test database in some other way.
$:.push File.dirname(__FILE__) + '/../source'
