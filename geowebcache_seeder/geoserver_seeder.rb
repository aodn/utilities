#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'logger'

require_relative 'layer_seeder'
require_relative 'geonetwork_connector'
require_relative 'geowebcache'

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

# Method for seeding all layers
#
# Params:
# * *Args*    :
#   - +layers+ -> Array of layers to seed
#   - +opts+ -> Arguments as passed to the executable, will contain start_zoom,
#     end_zoom etc.
# * *Returns* :
#   - true on success, false otherwise
#
def seed_layers(layers, opts)

    tiles_seed_count = 0

    layers.each do |layer|

        layer_seeder = LayerSeeder.new(layer, opts)
        tiles_seed_count += layer_seeder.execute
    end

    $logger.info "Total layers processed in operation: '#{tiles_seed_count}'"

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

    geonetwork_layers = []
    layers_to_seed = []

    if opts[:geonetwork]
        geonetwork_connector = GeonetworkConnector.new(opts)
        # layers that match supplied WMS server or all layers on Geonetwork
        geonetwork_layers = geonetwork_connector.wms_layers
    end

    # layers from command line
    if opts[:layers]
        opts[:layers].each do | layer|

            if(geonetwork_layers.any? {|geolayer| geolayer[1] == layer})
                layers_to_seed.push([opts[:geoserver], layer])
            else
                server = (opts[:geoserver].nil?) ? 'UNKNOWN WMS server' : opts[:geoserver]
                geonetwork = (opts[:geonetwork].nil?) ? 'UNKNOWN Geonetwork' : opts[:geonetwork]
                $logger.error("Layer not found: #{layer} on #{server} from #{geonetwork}")
                layers_to_seed.push([nil, layer])
            end
        end

        return seed_layers(layers_to_seed, opts)
    else
        return seed_layers(geonetwork_layers, opts)
    end
end

# Arguments parsing
opts = Trollop::options do
    banner <<-EOS
    Seed Geoserver tiles based on results returned from Geonetwork

    Examples:
        (dry run) Seed Geowebcache with all layers in catalogue-imos.aodn.org.au, zoom level 2 to default:
           geoserver_seeder.rb -d -u https://catalogue-imos.aodn.org.au/geonetwork -s 2 

        (dry run) Seed  all layers in catalogue-imos.aodn.org.au from http://maps.aims.gov.au/geoserver/wms
            geoserver_seeder.rb -d -u https://catalogue-imos.aodn.org.au/geonetwork -g http://maps.aims.gov.au/geoserver/wms

        (dry run) Seed the argo and aatams layers, zoom level 4 to 6:
           geoserver_seeder.rb -T reseed  -d -u https://catalogue-portal.aodn.org.au/geonetwork -l imos:argo_profile_layer_map imos:aatams_sattag_nrt_profile_map -g http://geoserver-123.aodn.org.au/geoserver/wms  -s 4 -e 6 

        (dry run) Truncate the argo layer without reference to the geoserver or catalogue:
           geoserver_seeder.rb -T truncate  -d  -l imos:argo_profile_layer_map 

    Options:
    EOS
    opt :geonetwork, "Geonetwork URL to use",
        :type => :string,
        :short => '-u'
    opt :geoserver, "Geoserver URL",
        :type => :string,
        :short => '-g'
    opt :type, 'truncate or seed',
        :type => :string,
        :short => '-T', :default => 'seed'
    opt :start_zoom, 'Zoom level to start with',
        :type => :int,
        :short => '-s', :default => 2
    opt :end_zoom, 'Zoom level to end with (8 if not specified)',
        :type => :int,
        :short => '-e', :default => 8
    opt :layers, 'Layers to seed',
        :type => :strings,
        :short => '-l'
    opt :dry_run, 'Dry run, only print commands',
        :type => :boolean,
        :short => '-d'
end

if __FILE__ == $0
    Trollop::die :geonetwork, 'Must specify Geonetwork url or layers' if !opts[:geonetwork]  && !opts[:layers]
    Trollop::die :type, 'Must specify Geowecache request type: truncate, reseed or seed' if !opts[:type]
    exit(geoserver_seeder_main(opts))
end
