#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'net/http'
require 'net/https'

TILE_SEEDER = "./tile_seeder.js"
TILE_SIZE   = 256
TILE_GUTTER = 20
GEONETWORK_SEARCH_REQUEST = "srv/eng/xml.search.summary?sortBy=popularity&from=1&to=999&fast=index"

class SquidLayerSeeder
  def initialize(layer, zoom_level, geoserver_address, thread_count, bbox, dry_run)
     @layer             = layer
     @zoom_level        = zoom_level
     @geoserver_address = geoserver_address
     @thread_count      = thread_count
     @bbox              = bbox || ""
     @dry_run           = dry_run
  end

  # Method for generating a list of URLs for seeding the given layer in the given
  # zoom level, by calling the js utility of tile_seeder.js
  #
  # Params:
  # * *Returns* :
  #   - Array of URLs for the given layer in the given zoom level
  #
  def url_list()
    return `#{TILE_SEEDER} #{@zoom_level} #{@layer} #{TILE_SIZE} #{TILE_GUTTER}`.split("\n")
  end

  # Run squidclient against given URLs
  #
  # Params:
  # * *Args*    :
  #   - +urls+ -> List of URLs to seed with squidclient
  # * *Returns* :
  #   - Array of URLs for the given layer in the given zoom level
  #
  def squidclient(urls)
    urls.each do |url|
      full_url = "#{@geoserver_address}?#{url}"
      cmd      = "squidclient -s -m GET '#{full_url}'"
      if @dry_run
        puts cmd
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
  def seed()
    puts "Seeding geoserver: '#{@geoserver_address}', zoom_level: '#{@zoom_level}', layer: '#{@layer}'"
    threads = []

    # Get URL list and divide to the same number of slices as we have threads
    divide_to_slices(url_list(), @thread_count).each do |url_work_slice|
      thr = Thread.new do
        squidclient(url_work_slice)
      end
      threads << thr
    end

    # Wait on all threads
    threads.each do |thread|
      thread.join(1)
    end
  end

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
  def wms_link()
    wms_link = [nil, nil]
    @links.each do |link|
      link_parts = link.split("|")
      if link_parts[3] == 'OGC:WMS-1.1.1-http-get-map'
        wms_link = [ link_parts[2], link_parts[0] ]
      end
    end

    return wms_link
  end

end

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
def local_geoserver_address(opts)
  geoserver_url = URI(opts[:geoserver])
  return "http://localhost:#{opts[:port]}#{geoserver_url.path}"
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
  thread_count      = opts[:threads]
  bbox              = opts[:bbox]
  dry_run           = opts[:dry_run]
  geoserver_wms_url = local_geoserver_address(opts)

  for zoom_level in start_zoom..end_zoom
    layers.each do |layer|
      layer_seeder = SquidLayerSeeder.new(
        layer, zoom_level, geoserver_wms_url, thread_count, bbox, dry_run
      )
      layer_seeder.seed()
    end
  end

  return true
end

# Method for seeding all layers found in given Geonetwork instance using
# Geoserver at given address
#
# Params:
# * *Args*    :
#   - +opts+ -> Arguments as passed to the executable
# * *Returns* :
#   - Array of layer names
#
def get_layers_from_geonetwork(opts)
  geoserver_url  = opts[:geoserver]
  # Append search parameters to geonetwork request
  geonetwork_url = "#{opts[:geonetwork]}/#{GEONETWORK_SEARCH_REQUEST}"
  layers = []

  geonetwork_search_results = Net::HTTP.get(URI.parse(geonetwork_url))
  geonetwork_search_results_xml = Nokogiri::XML(geonetwork_search_results)

  geonetwork_search_results_xml.at_xpath("/response").children.each do |metadata|
    next unless metadata.name == 'metadata'

    geonetwork_links = GeonetworkMetadataLinks.new(metadata)
    wms_server, wms_layer = geonetwork_links.wms_link()

    if wms_server == geoserver_url && wms_layer
      puts "Probed layer from Geonetwork: '#{wms_layer}' on '#{wms_server}'"
      layers << wms_layer
    end

  end

  return layers

end

# Main method for this utility script
#
# Params:
# * *Args*    :
#   - +opts+ -> Arguments as passed to the executable
# * *Returns* :
#   - true on success, false otherwise
#
def geoserver_seeder(opts)
  layers = []

  if opts[:geonetwork]
    # Get layers from Geonetwork URL
    layers = get_layers_from_geonetwork(opts)
  else
    # Get layers from command line
    layers = opts[:layers]
    puts layers
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
           geoserver_seeder.rb -u http://catalogue-123.aodn.org.au/geonetwork 
             -g http://geoserver-123.aodn.org.au/geoserver/wms 
             -s 2 -e 2 -t 2

        Seed the argo and aatams layers, zoom level 4 to 6, 8 threads:
           geoserver_seeder.rb
             -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map
             -g http://geoserver-123.aodn.org.au/geoserver/wms 
             -s 4 -e 6 -t 8

    Options:
EOS
  opt :geonetwork, "Geonetwork URL to use",
    :type => :string,
    :short   => '-u'
  opt :geoserver, "Geoserver URL",
    :type => :string,
    :short   => '-g'
  opt :threads, "Number of threads to run",
    :type => :int,
    :short   => '-t', :default => 1
  opt :port, "Geoserver port",
    :type => :int,
    :short   => '-p', :default => 8080
  opt :start_zoom, "Zoom level to start with",
    :type => :int,
    :short   => '-s', :default => 2
  opt :end_zoom, "Zoom level to end with",
    :type => :int,
    :short   => '-e', :default => 6
  opt :layers, "Layers to seed",
    :type => :strings,
    :short   => '-l'
  opt :bbox, "Bounding box to seed",
    :type => :int,
    :short   => '-b'
  opt :dry_run, "Dry run, only print commands",
    :type => :boolean,
    :short   => '-d'
end

Trollop::die :geonetwork, "Must specify Geonetwork url or layers" if ! opts[:geonetwork] && ! opts[:layers]
Trollop::die :geoserver,  "Must specify Geoserver url"            if ! opts[:geoserver]

exit(geoserver_seeder(opts))
