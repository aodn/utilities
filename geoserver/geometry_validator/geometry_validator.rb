#!/usr/bin/ruby

require 'pg'
require 'getoptlong'

$stdout.sync = true

def verify_column(connection, schema, table, column)
  puts "---"
  puts "Verifying #{schema}.#{table}.#{column}"
  begin
    res = connection.exec("SELECT ST_IsValidReason(#{column}), * FROM #{schema}.#{table} WHERE NOT ST_IsValid(#{column})")
    res.each do |row|
      puts row
    end
  rescue
    puts "Exception while processing #{schema}.#{table}.#{column}"
  end
  puts "---"
end

def usage
  puts <<-EOF
geometry_validator.rb [OPTION] ...

-h, --help:
   show help

--host HOST, -H HOST:
   Host to connect to

--port PORT, -p PORT:
   Port to connect to

--database DB, -d DB:
   Database to connect to

--username USER, -u USER:
   Username to conenct with

--password PASSWORD, -P PASSWORD:
   Passwod to connect with

EOF
  exit
end

def main
  opts = GetoptLong.new(
    [ '--help',     '-h', GetoptLong::NO_ARGUMENT ],
    [ '--host',     '-H', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--port',     '-p', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--database', '-d', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--username', '-u', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--password', '-P', GetoptLong::REQUIRED_ARGUMENT ]
  )

  hostname = "localhost"
  port     = 5432
  database = "test"
  username = "postgres"
  password = "postgres"

  opts.each do |opt, arg|
  case opt
    when '--help'
      usage
    when '--host'
      hostname = arg
    when '--port'
      port = arg
    when '--database'
      database = arg
    when '--username'
      username = arg
    when '--password'
      password = arg
    end
  end

  connection = PGconn.connect(hostname, port, '', '', database, username, password)

  res = connection.exec("SELECT table_schema, table_name, column_name FROM information_schema.columns where data_type = 'USER-DEFINED' and udt_name = 'geometry'")
  # Alternatively, on a clean database (db-harvest-prod.aodn.org.au/harvest), you can run:
  # res = connection.exec("SELECT f_table_schema as table_schema, f_table_name as table_name, f_geometry_column as column_name FROM geometry_columns")

  res.each do |row|
    schema = row['table_schema']
    table  = row['table_name']
    column = row['column_name']
    puts "Verifying #{schema}.#{table}.#{column}"
    verify_column connection, schema, table, column
  end
end

main
