#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'logger'

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

class TileGenerator

  LON_MIN = -180
  LON_MAX = 180
  LAT_MIN = -90
  LAT_MAX = 90

  def flip_lon_lat(bbox)
    return [bbox[1], bbox[0], bbox[3], bbox[2]]
  end

  def intersects(left_bbox, right_bbox)
    return !(
      right_bbox[0] > left_bbox[2] ||
      right_bbox[2] < left_bbox[0] ||
      right_bbox[1] > left_bbox[3] ||
      right_bbox[3] < left_bbox[1]
    )
  end

  def to_bbox_with_gutter(left, bottom, tile_dimension, gutter_dimension)
    _right = left + tile_dimension + gutter_dimension
    _top = bottom + tile_dimension + gutter_dimension
    _left = left - gutter_dimension
    _bottom = bottom - gutter_dimension

    return [_left, _bottom, _right, _top]
  end

  def generate_tiles(zoom_level, layer_bbox, tile_size_px, gutter_px, version)
    bounding_boxes = []

    # Tile dimension in degress
    tile_dimension = 180.0 / (2 ** zoom_level)
    # Gutter dimension in degress
    gutter_dimension = gutter_px * tile_dimension / tile_size_px

    (LON_MIN..(LON_MAX - tile_dimension)).step(tile_dimension) do |lon|
      (LAT_MIN..(LAT_MAX - tile_dimension)).step(tile_dimension) do |lat|
        bbox = to_bbox_with_gutter(lon, lat, tile_dimension, gutter_dimension)
        next unless (layer_bbox.nil? || intersects(layer_bbox, bbox))

        version == "1.3.0" && bbox = flip_lon_lat(bbox)

        bounding_boxes << bbox
      end
    end

    return bounding_boxes
  end
end

class SquidLayerSeeder
  def initialize(opts)
     @layer             = opts[:layer]
     @zoom_level        = opts[:zoom_level]
     @url_format        = opts[:url_format]
     @version           = opts[:version] || "1.1.1"
     @tile_size         = opts[:tile_size]
     @gutter_size       = opts[:gutter_size]
     @geoserver_wms_url = opts[:geoserver_wms_url]
     @threads           = opts[:threads]
     @bbox              = opts[:bbox] || nil
     @dry_run           = opts[:dry_run]
     @purge             = opts[:purge]
  end

  # Method for generating a list of URLs for seeding the given layer in the given
  # zoom level, by calling the js utility of tile_seeder.js
  #
  # Params:
  # * *Returns* :
  #   - Array of URLs for the given layer in the given zoom level
  #
  def url_list
    url_list = []
    tile_generator = TileGenerator.new
    tile_size_with_gutter = @tile_size + (2 * @gutter_size)
    tile_generator.generate_tiles(@zoom_level, @bbox, @tile_size, @gutter_size, @version).each do |tile_bbox|
      url = @url_format % {
        :layer_name => @layer.gsub(":", "%3A"),
        :version    => @version,
        :bbox       => tile_bbox.join(","),
        :width      => tile_size_with_gutter,
        :height     => tile_size_with_gutter
      }
      url_list << url
    end
    return url_list
  end

  # Run squidclient against given URLs
  #
  # Params:
  # * *Args*    :
  #   - +urls+ -> List of URLs to seed with squidclient
  # * *Returns* :
  #   - Array of URLs for the given layer in the given zoom level
  #
  def self.squidclient(url_prefix, urls, dry_run, purge = false)
    squidclient_command = purge ? "PURGE" : "GET"
    urls.each do |url|
      full_url = "#{url_prefix}#{url}"
      cmd      = "squidclient -s -m #{squidclient_command} '#{full_url}'"
      if dry_run
        $logger.info cmd
      else
        system(cmd)
      end
    end
  end

  # Divides array into slices
  #
  # Params:
  # * *Args*    :
  #   - +array+ -> Array to slice
  #   - +slice_count+ -> Number of slices to generate
  # * *Returns* :
  #   - Array of arrays, divided into slices
  #
  def divide_to_slices(array, slice_count)
    slice_size = ((array.length.to_f / slice_count).ceil).to_i
    return array.each_slice(slice_size)
  end

  # Seeds the given layer
  #
  # Params:
  # * *Returns* :
  #   - Total number of tiles seeded
  #
  def seed
    urls = url_list

    $logger.info "Seeding geoserver: '#{@geoserver_wms_url}', \
zoom_level: '#{@zoom_level}', \
tiles: '#{urls.length}', \
layer: '#{@layer}'"
    threads = []

    # Get URL list and divide to the same number of slices as we have threads
    divide_to_slices(urls, @threads).each do |url_work_slice|
      thr = Thread.new do
        if @purge
          SquidLayerSeeder::squidclient("#{@geoserver_wms_url}?", url_work_slice, @dry_run, true)
        end
        SquidLayerSeeder::squidclient("#{@geoserver_wms_url}?", url_work_slice, @dry_run)
      end
      threads << thr
    end

    # Wait on all threads
    threads.each do |thread|
      thread.join
    end

    return urls.length
  end

end


class GeonetworkConnector

  GEONETWORK_SEARCH_REQUEST = "srv/eng/xml.search.summary?sortBy=popularity&from=1&to=999&fast=index"

  def initialize(geonetwork_url, geoserver_url)
    @geonetwork_url = "#{geonetwork_url}/#{GEONETWORK_SEARCH_REQUEST}"
    @geoserver_url  = geoserver_url
  end

  # Method for connecting to a given geonetwork url and extract wms layers
  #
  # Params:
  # * *Returns* :
  #   - Array of layers in geonetwork
  #
  def wms_layers
    geonetwork_search_results = URI.parse(@geonetwork_url).read
    geonetwork_search_results_xml = Nokogiri::XML(geonetwork_search_results)

    layers = []
    geonetwork_search_results_xml.at_xpath("/response").children.each do |metadata|
      next unless metadata.name == 'metadata'

      geonetwork_links = GeonetworkMetadataLinks.new(metadata)
      wms_server, wms_layer = geonetwork_links.wms_link

      if wms_server == @geoserver_url && wms_layer
        $logger.info "Probed layer from Geonetwork: '#{wms_layer}' on '#{wms_server}'"
        layers << wms_layer
      end
    end

    return layers
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

    # Method for extracting WMS server name and WMS layer name from given
    # Geonetwork links
    #
    # Params:
    # * *Returns* :
    #   - WMS server link
    #   - Layer name on WMS server
    #
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

# Class to hold utility functions
class Utils

  # Returns local Geoserver WMS address for use with squidclient
  #
  # Params:
  # * *Args*    :
  #   - +opts+ -> Arguments as passed to the executable
  #
  # * *Returns* :
  #   - Local WMS Geoserver address for squidclient, such as
  #     'http://localhost:8080/geoserver/wms'
  #
  def self.local_geoserver_address(opts)
    geoserver_url = URI(opts[:geoserver])
    return "http://localhost:#{opts[:port]}#{geoserver_url.path}"
  end

  # Method for formatting a url format string to be used in operation
  #
  # Params:
  # * *Args*    :
  #   - +url+ -> Sample URL
  # * *Returns* :
  #   - A format string of the url
  #
  def self.get_url_format_from_url(url)
    url_format = url.dup

    # Escape all % for formatting
    url_format.gsub!("%", "%%")

    # Replace variables that we are going to deal with
    url_format.gsub!(/LAYERS=[^&]+/,  "LAYERS=%{layer_name}")
    url_format.gsub!(/VERSION=[^&]+/, "VERSION=%{version}")
    url_format.gsub!(/BBOX=[^&]+/,    "BBOX=%{bbox}")
    url_format.gsub!(/WIDTH=[^&]+/,   "WIDTH=%{width}")
    url_format.gsub!(/HEIGHT=[^&]+/,  "HEIGHT=%{height}")

    return url_format
  end

end

# Method for seeding all layers iteratively, starting from the highest zoom
# level and digging down
#
# Params:
# * *Args*    :
#   - +layers+ -> Array of layers to seed
#   - +opts+ -> Arguments as passed to the executable, will contain start_zoom,
#     end_zoom, bbox etc.
# * *Returns* :
#   - true on success, false otherwise
#
def seed_layers(layers, opts)
  start_zoom        = opts[:start_zoom]
  end_zoom          = opts[:end_zoom]
  geoserver_wms_url = Utils::local_geoserver_address(opts)
  url_format        = Utils::get_url_format_from_url(opts[:url])
  tiles_seed_count  = 0

  for zoom_level in start_zoom..end_zoom
    layers.each do |layer|
      opts_for_squid_layer_seeder                     = opts.dup
      opts_for_squid_layer_seeder[:layer]             = layer
      opts_for_squid_layer_seeder[:zoom_level]        = zoom_level
      opts_for_squid_layer_seeder[:geoserver_wms_url] = geoserver_wms_url
      opts_for_squid_layer_seeder[:url_format]        = url_format

      layer_seeder = SquidLayerSeeder.new(opts_for_squid_layer_seeder)
      tiles_seed_count += layer_seeder.seed
    end
  end

  $logger.info "Total tiles seeded in operation: '#{tiles_seed_count}'"

  return true
end

# Main method for this utility script
#
# Params:
# * *Args*    :
#   - +opts+ -> Arguments as passed to the executable
# * *Returns* :
#   - true on success, false otherwise
#
def geoserver_seeder_main(opts)
  layers = []

  if opts[:geonetwork]
    # Get layers from Geonetwork URL
    geonetwork_connector = GeonetworkConnector.new(opts[:geonetwork], opts[:geoserver])
    layers = geonetwork_connector.wms_layers
  else
    # Get layers from command line
    layers = opts[:layers]
  end

  return seed_layers(layers, opts)
end

# Arguments parsing
opts = Trollop::options do
  banner <<-EOS
    Seed Geoserver tiles based on results returned from Geonetwork

    Examples:
        Seed Geoserver with all layers in catalogue-123.aodn.org.au, zoom level
        2 to 5, 4 threads:
           geoserver_seeder.rb -u https://catalogue-123.aodn.org.au/geonetwork
             -g http://geoserver-123.aodn.org.au/geoserver/wms
             -s 2 -e 2 -t 2 -T 256 -G 20

        Seed the argo and aatams layers, zoom level 4 to 6, 8 threads:
           geoserver_seeder.rb
             -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map
             -g http://geoserver-123.aodn.org.au/geoserver/wms
             -s 4 -e 6 -t 8 -T 256 -G 20

    Options:
EOS
  opt :geonetwork, "Geonetwork URL to use",
    :type  => :string,
    :short => '-u'
  opt :geoserver, "Geoserver URL",
    :type  => :string,
    :short => '-g'
  opt :threads, "Number of threads to run",
    :type  => :int,
    :short => '-t', :default => 1
  opt :purge, "Purge URLs before hitting them",
    :type  => :boolean,
    :short => '-P', :default => false
  opt :port, "Geoserver port",
    :type  => :int,
    :short => '-p', :default => 8080
  opt :start_zoom, "Zoom level to start with",
    :type  => :int,
    :short => '-s', :default => 2
  opt :end_zoom, "Zoom level to end with",
    :type  => :int,
    :short => '-e', :default => 6
  opt :tile_size, "Tile size in pixels",
    :type  => :int,
    :short => '-T', :default => 256
  opt :gutter_size, "Gutter size of tiles in pixels",
    :type  => :int,
    :short => '-G', :default => 20
  opt :layers, "Layers to seed",
    :type  => :strings,
    :short => '-l'
  opt :bbox, "Bounding box to seed",
    :type  => :int,
    :short => '-b'
  opt :dry_run, "Dry run, only print commands",
    :type  => :boolean,
    :short => '-d'
  opt :url, "URL sample",
    :type  => :string,
    :short => '-U'
  opt :wms_version, "WMS version",
    :type  => :string,
    :short => '-v'
end

if __FILE__ == $0
  Trollop::die :geonetwork, "Must specify Geonetwork url or layers" if ! opts[:geonetwork] && ! opts[:layers]
  Trollop::die :geoserver,  "Must specify Geoserver url"            if ! opts[:geoserver]
  Trollop::die :url,        "Must specify url format"               if ! opts[:url]
  exit(geoserver_seeder_main(opts))
end
