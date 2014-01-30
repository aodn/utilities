#!/usr/bin/env ruby

require 'cgi/util'
require 'logging'
require 'net/http'
require 'nokogiri'
require 'optparse'

class GeoserverLinkCatter

  READ_TIMEOUT = 20

  attr_accessor :timed_out_layers
  @timed_out_layers

  attr_accessor :logger
  @logger

  # Output link statuses.
  attr_accessor :statuses
  @statuses

  # Keep a mapping of link to layer (for traceability).
  attr_accessor :links_to_layers
  @links_to_layers

  def initialize(argv)
    @logger = Logging.logger(STDERR)
    @logger.level = :warn
    parse_options(argv)
    @timed_out_layers = []
    @statuses = {}
    @links_to_layers = {}
  end

  def parse_options(argv)
    options = {}

    optparse = OptionParser.new do|opts|

      opts.banner = "Usage: #{opts.program_name} <server URL> [options]"

      opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit 1
      end

      opts.on('-v', '--verbose', 'Verbose logging') do |arg|
        @logger.level = :debug
      end

      opts.on('--wms', 'WMS links only') do
        @wms_only = true
      end

      opts.on('--layers', 'Layer names only') do
        @layers_only = true
      end

    end

    optparse.parse!(argv)

    if (argv.length != 1)
      puts optparse
      exit 1
    end

    @url = argv[0]
    options
  end

  def construct_get_capabilities_request_url
    "#{@url}/wms?VERSION=1.1.1&REQUEST=GetCapabilities"
  end

  def construct_get_feature_info_request_url(layer_name)
    "#{@url}/wms?LAYERS=#{CGI::escape(layer_name)}&VERSION=1.1.1&SERVICE=WMS&REQUEST=GetFeatureInfo&BBOX=-180,-90,180,90&QUERY_LAYERS=#{CGI::escape(layer_name)}&FEATURE_COUNT=1000&SRS=EPSG:4326&WIDTH=1&HEIGHT=1&X=0&Y=0&INFO_FORMAT=text/html"
  end

  def construct_get_map_request_url(layer_name)

    # Whack a time param on the end, just to stop caching.
    "#{@url}/wms?LAYERS=#{CGI::escape(layer_name)}&TRANSPARENT=TRUE&VERSION=1.1.1&FORMAT=image%2Fpng&QUERYABLE=true&EXCEPTIONS=application%2Fvnd.ogc.se_xml&SERVICE=WMS&REQUEST=GetMap&STYLES=&SRS=EPSG%3A4326&BBOX=-180,-90,180,90&WIDTH=296&HEIGHT=296&time=#{Time.now.to_i}"
  end

  def get_layer_names

    layer_names = []
    response = Net::HTTP.get(URI(construct_get_capabilities_request_url))

    html_doc = Nokogiri::XML(response)
    html_doc.xpath('//Layer/Layer/Name').each do |e|
      layer_names << e.text
    end

    @logger.info "Layer count: #{layer_names.length}"
    layer_names
  end

  def new_http_for_uri(uri)
    uri = URI(uri)  # in case we've been given a string.
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = READ_TIMEOUT

    http
  end

  def get_links_for_wfs_layer(layer_name)
    links = []

    begin
      feature_info_request_url = construct_get_feature_info_request_url(layer_name)
      uri = URI(feature_info_request_url)

      http = new_http_for_uri(uri)
      @logger.debug "Getting links for layer: #{feature_info_request_url}"
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      html_doc = Nokogiri::HTML(response.body)
      html_doc.xpath('//a/@href').each do |a|
        links << a.value()
        @links_to_layers[a.value()] = feature_info_request_url
      end
    rescue Timeout::Error => e
      @timed_out_layers << layer_name
    end

    links
  end

  def get_links_for_all_layers
    links = []

    if @wms_only
      get_layer_names.each do |layer_name|
        links << construct_get_map_request_url(layer_name)
      end
    elsif @layers_only
      get_layer_names.each do |layer_name|
        links << layer_name
      end
    else
      get_layer_names.each do |layer_name|
        links << get_links_for_wfs_layer(layer_name)
      end
    end

    return links.flatten.uniq
  end

  def run
    get_links_for_all_layers.each do |link|
      puts link
    end
  end
end


if __FILE__ == $0

  checker = GeoserverLinkCatter.new(ARGV)
  checker.run

  exit 0
end
