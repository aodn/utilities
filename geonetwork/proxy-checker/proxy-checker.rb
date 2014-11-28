#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'logger'
require 'json'
require 'fileutils'

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

class GeonetworkConnector

  GEONETWORK_SEARCH_REQUEST = "srv/eng/xml.search.summary?sortBy=popularity&from=1&to=999&fast=index"

  def initialize(geonetwork_url)
    @geonetwork_url = "#{geonetwork_url}/#{GEONETWORK_SEARCH_REQUEST}"
  end

  # Method for connecting to a given geonetwork url and extract wms layers
  #
  # Params:
  # * *Returns* :
  #   - Array of layers in geonetwork
  #
  def servers
    geonetwork_search_results = URI.parse(@geonetwork_url).read
    geonetwork_search_results_xml = Nokogiri::XML(geonetwork_search_results)

    servers = []
    geonetwork_search_results_xml.at_xpath("/response").children.each do |metadata|
      next unless metadata.name == 'metadata'

      geonetwork_links = GeonetworkMetadataLinks.new(metadata)
      wms_server, wms_layer = geonetwork_links.wms_link

      if wms_server && "" != wms_server
        $logger.debug "Probed server from Geonetwork: '#{wms_server}'"
        servers << wms_server
      end
    end

    return servers.sort.uniq!
  end

  class GeonetworkMetadataLinks
    def initialize(metadata_xml)
      # Extract links from metadata record
      @links = []
      metadata_xml.children.each do |link|
        next unless link.name == 'link'
        @links << link.inner_text
      end
    end

    def wms_link
      wms_link = [nil, nil]
      @links.each do |link|
        link_parts = link.split("|")
        if link_parts[3] == 'OGC:WMS-1.1.1-http-get-map'
          wms_link = [ link_parts[2], link_parts[0] ]
        end
      end

      return wms_link
    end
  end # class GeonetworkConnector

end

def is_server_allowed(portal, server)
  url = "#{portal}/proxy?url=#{URI::encode(server)}"
  res = Net::HTTP.get_response(URI(url))
  return res.code.to_i == 200
end

def proxy_checker_main(opts)
  layers = []

  # Get layers from Geonetwork URL
  geonetwork_connector = GeonetworkConnector.new(opts[:geonetwork])
  servers = geonetwork_connector.servers

  portal = opts[:portal]

  servers.each do |server|
    if is_server_allowed(portal, server)
      $logger.info "Server '#{server}' is allowed via '#{portal}'"
    else
      $logger.warn "Server '#{server}' is NOT ALLOWED via '#{portal}'"
    end
  end

  return 0
end

# Arguments parsing
opts = Trollop::options do
  banner <<-EOS
    Verify metadata record online resources via portal proxy

    Examples:
        Check that all records in catalogue-123.aodn.org.au are allowed in imos.aodn.org.au:
           proxy-checker.rb -u https://catalogue-123.aodn.org.au/geonetwork
             -p https://imos.aodn.org.au/imos123

    Options:
EOS
  opt :geonetwork, "Geonetwork URL",
    :type  => :string,
    :short => '-u'
  opt :portal, "Portal URL",
    :type  => :string,
    :short => '-p'
end

if __FILE__ == $0
  Trollop::die :geonetwork, "Must specify Geonetwork url or layers" if ! opts[:geonetwork]
  Trollop::die :portal,     "Must specify Portal url"               if ! opts[:portal]
  exit(proxy_checker_main(opts))
end
