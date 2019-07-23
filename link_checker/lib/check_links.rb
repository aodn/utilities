#!/usr/bin/env ruby

require 'cgi/util'
require 'logging'
require 'net/http'
require 'nokogiri'
require 'optparse'
require_relative 'thread-pool'

class LinkChecker

  READ_TIMEOUT = 20

  attr_accessor :logger
  @logger

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
    @logger = Logging.logger(STDERR)
    @logger.level = :warn
    parse_options(argv)
    @statuses = {}
    @links_to_layers = {}
  end

  def parse_options(argv)
    options = {}

    optparse = OptionParser.new do|opts|

      opts.banner = "Usage: #{opts.program_name} [FILE]... [options]"

      opts.on('-h', '--help', 'Display this screen' ) do
        puts opts
        exit 1
      end

      opts.on('-v', '--verbose', 'Verbose logging' ) do |arg|
        @logger.level = :debug
      end

      opts.on('-t', '--threads NUM', Integer, 'Threads to use') do |num_threads|
        @pool = Pool.new(num_threads)
      end
    end

    optparse.parse!(argv)

    # if (argv.length != 1)
    #   puts optparse
    #   exit 1
    # end

    # @url = argv[0]
    options
  end

  def new_http_for_uri(uri)
    uri = URI(uri)  # in case we've been given a string.
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = READ_TIMEOUT

    http
  end

  def collect_link_statuses(links)

    @links_to_check = links

    @logger.info "Links count: #{@links_to_check.length}"

    @links_to_check.each_with_index do |link, i|
      query_link_status(link)
    end
  end

  def query_link_status(link)

    if @pool
      @pool.schedule do
        make_request(link)
      end
    else
      make_request(link)
    end
  end

  def make_request(link)
    if @links_to_check then @logger.info "checking link #{link}, (#{@statuses.length}/#{@links_to_check.length}) approx" end

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

  def run

    collect_link_statuses(ARGF.readlines.collect { |i| i.chomp })

    # Wait for threads to finish (if necessary).
    if @pool
      @pool.shutdown
    end

    @statuses.each do |link, status|
      puts "\"#{link}\",\"#{status}\""
    end

  end
end


if __FILE__ == $0

  checker = LinkChecker.new(ARGV)
  checker.run

  exit 0
end
