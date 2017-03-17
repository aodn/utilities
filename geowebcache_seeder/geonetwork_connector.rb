#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'logger'

class GeonetworkConnector

    GEONETWORK_SEARCH_REQUEST = "srv/eng/xml.search.summary?sortBy=popularity&from=1&to=999&fast=index"

    def initialize(opts)
        @geonetwork_url = "#{opts.geonetwork}/#{GEONETWORK_SEARCH_REQUEST}"
        @geoserver = "#{opts.geoserver}"
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

            if wms_layer && (@geoserver.empty? || wms_server == @geoserver)
                $logger.info "Probed layer from Geonetwork: '#{wms_layer}' on '#{wms_server}'"
                layers << geonetwork_links.wms_link
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
                if (link_parts[3].include? 'http-get-map') && (link_parts[3].include? 'OGC:WMS-')
                    wms_link = [link_parts[2], link_parts[0]]
                end
            end

            return wms_link
        end
    end
end
