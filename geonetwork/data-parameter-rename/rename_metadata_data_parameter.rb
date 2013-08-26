#!/usr/bin/env ruby

require 'bundler/setup'
require 'pg'
require 'nokogiri'

class MetadataDataParameterRenamer

  def initialize(host, database, user, password)
    @host = host
    @database = database
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
    @connection = PG.connect(:host => @host, :dbname => @database, :user => @user, :password => @password)
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
  puts "Searching for data parameter #{ARGV[4]} and replacing with #{ARGV[5]}"
  MetadataDataParameterRenamer.new(ARGV[0], ARGV[1], ARGV[2], ARGV[3]).update_metadata(ARGV[4], ARGV[5])
end

main
