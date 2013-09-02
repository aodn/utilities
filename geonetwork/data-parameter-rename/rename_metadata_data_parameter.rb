#!/usr/bin/env ruby

require 'bundler/setup'
require 'trollop'
require 'pg'
require 'nokogiri'

class MetadataDataParameterRenamer

  def initialize(host, database, port, user, password)
    @host = host
    @database = database
    @port = port
    @user = user
    @password = password
  end

  def update_metadata(search, replace)
    begin
      connect
      read(search).each do |record|
        replace(record, search, replace)
      end
    ensure
      disconnect
    end
  end

  private

  def connect
    @connection = PG.connect(:host => @host, :dbname => @database, :port => @port, :user => @user, :password => @password)
  end

  def disconnect
    @connection.close
  end

  def update(data, uuid)
    puts "Update #{uuid}"
    @connection.exec('UPDATE metadata set data = $1 where uuid = $2', [data, uuid])
  end

  def read(search)
    @connection.exec("SELECT * from metadata where data like '%#{search}%'")
  end

  def replace(record, search, replace)
    doc  = Nokogiri::XML(record['data'])
    doc.xpath(xpath).each do |param|
      if param.content == search
        param.content = replace
        update(doc.to_s, record['uuid'])
      end
    end
  end

  def xpath
    '//mcp:MD_Metadata/gmd:identificationInfo/mcp:MD_DataIdentification/mcp:dataParameters/mcp:DP_DataParameters/mcp:dataParameter/mcp:DP_DataParameter/mcp:parameterName/mcp:DP_ParameterName/mcp:name/gco:CharacterString'
  end

end

def main
  opts = Trollop::options do
    opt :host,     "host",     :default => 'emii3-vm1.its.utas.edu.au'
    opt :database, "database", :default => 'imosmest'
    opt :port,     "port",     :default => 5432
    opt :username, "username", :default => 'postgres'
    opt :password, "password", :type    => :string, :short => 'w'
    opt :search,   "search",   :type    => :string
    opt :replace,  "replace",  :type    => :string
    banner <<-EOS
Bulk search and replace a data parameter name in GeoNetwork Metadata
EOS
  end

  Trollop::die :password, "required" if opts[:password].nil?
  Trollop::die :search, "required" if opts[:search].nil?

  puts "Searching for data parameter '#{opts[:search]}' and replacing with '#{opts[:replace]}'"
  MetadataDataParameterRenamer.new(opts[:host], opts[:database], opts[:port], opts[:username], opts[:password]).update_metadata(opts[:search], opts[:replace])
end

main
