#!/usr/bin/env ruby

require 'cgi/util'
require 'logging'
require 'net/http'
require 'nokogiri'
require 'optparse'
require_relative 'thread-pool'

class GeoserverLinkChecker

  READ_TIMEOUT = 20

  attr_accessor :timed_out_layers
  @timed_out_layers

  attr_accessor :reject_links
  @reject_links

  attr_accessor :logger
  @logger

  attr_accessor :out_filename
  @out_filename

  attr_accessor :checked_links_filename
  @checked_links_filename

  # Thread pool - check links concurrently.
  attr_accessor :pool
  @pool

  # Output link statuses.
  attr_accessor :statuses
  @statuses

  # Keep a mapping of link to layer (for traceability).
  attr_accessor :links_to_layers
  @links_to_layers

  def initialize(argv)
    @reject_links = [/^mailto.*/, /#/, /^\s*$/]
    @logger = Logging.logger(STDOUT)
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

      opts.on('-h', '--help', 'Display this screen' ) do
        puts opts
        exit 1
      end

      opts.on('-v', '--verbose', 'Verbose logging' ) do |arg|
        @logger.level = :debug
      end

      opts.on('-r', '--reject FILE', 'Reject links filename') do |filename|
        @reject_links += File.readlines(filename).collect do |line|
          Regexp.new(line.chomp)
        end
      end

      opts.on('-o', '--output FILE', 'Output link status filename') do |filename|
        @out_filename = filename
      end

      opts.on('-c', '--checked FILE', 'Checked links filename') do |filename|
        @checked_links_filename = filename
      end

      opts.on('-t', '--threads NUM', Integer, 'Threads to use') do |num_threads|
        @pool = Pool.new(num_threads)
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

  def get_links_for_layer(layer_name)
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

    get_layer_names.each do |layer_name|
      links << get_links_for_layer(layer_name)
    end

    # Return unique links - shuffled so as to spread the load on destination servers
    # somewhat.
    return links.flatten.uniq.shuffle
  end

  def filter_links(links)
    links.reject do |link|

      rejected = false
      @reject_links.each do |reject_pattern|
        if (reject_pattern.match(link))
          rejected = true
          break
        end
      end

      rejected
    end
  end

  def query_link_status(link)

    # Keep track of files already checked.
    if (@checked_links_filename)
      File.open(@checked_links_filename, 'a') do |file|
        file.puts link
      end
    end

    if @pool
      @pool.schedule do
        make_request(link)
      end
    else
      make_request(link)
    end
  end

  def make_request(link)
    if @links_to_check
      @logger.info "checking link #{link}, (#{@statuses.length}/#{@links_to_check.length}) approx"
    end

    begin
      uri = URI(link)
      http = new_http_for_uri(uri)
      request = Net::HTTP::Head.new(uri.request_uri)

      response = http.request(request)
      @statuses[link] = response.code.to_i()
    rescue Exception => e
      @statuses[link] = e
    end
    @logger.info "link #{link}, status: #{statuses[link]}"
  end

  def collect_link_statuses(links)

    @links_to_check = links

    @logger.info "Links count: #{@links_to_check.length}"

    @links_to_check.each_with_index do |link, i|
      query_link_status(link)
    end
  end

  def statuses_to_exit_code(statuses)
    statuses.each do |link, status|
      if (status != 200)
        # TODO: logging
        return 1
      end
    end

    return 0
  end

  def run
    unfiltered_links = get_links_for_all_layers
    filtered_links = filter_links(unfiltered_links)

    @logger.info "unfiltered link count: #{unfiltered_links.length}, filtered link count: #{filtered_links.length}"

    collect_link_statuses(filtered_links)

    # Wait for threads to finish (if necessary).
    if @pool
      @pool.shutdown
    end

    if (@out_filename)
      File.open(@out_filename, 'w') do |file|
        @statuses.each do |link, status|
          file.puts "\"#{link}\",\"#{status}\",\"#{links_to_layers[link]}\""
        end
      end
    else
      @statuses.each do |link, status|
        puts "#{link},#{status},#{links_to_layers[link]}"
      end
    end
  end
end


if __FILE__ == $0

  checker = GeoserverLinkChecker.new(ARGV)
  checker.run

  exit 0
end
