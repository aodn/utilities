#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'trollop'
require 'net/http'
require 'net/https'
require 'open-uri'
require 'logger'

class LayerSeeder
    def initialize(layer, opts)
        @geowebcache = Geowebcache.new()
        @layer = layer
        @start_zoom = opts[:start_zoom]
        @end_zoom = opts[:end_zoom]
        @geonetwork = opts[:geonetwork]
        @geoserver = opts[:geoserver]
        @dry_run = opts[:dry_run]
        @type = opts[:type]
    end

    def purgeCache

        geowebcacheUrl = "#{@geowebcache.url}/rest/seed/#{@layer[1]}"

        options = "<seedRequest>"\
            "<name>#{@layer[1]}</name>"\
              "<srs>"\
                "<number>4326</number>"\
                    "</srs>"\
              "<zoomStart>1</zoomStart>"\
              "<zoomStop>20</zoomStop>"\
              "<format>image/png</format>"\
              "<type>truncate</type>"\
           "</seedRequest>"

        # kill all previous threads for layer
        killcmd = "curl -v -u #{@geowebcache.username}:#{@geowebcache.password}  -d \"kill_all=all\"  \"#{geowebcacheUrl}\""
        # clear all tiles for layer
        cmd = "curl -v -u #{@geowebcache.username}:#{@geowebcache.password} -XPOST -H \"Content-type: text/xml\" -d \"#{options}\" \"#{geowebcacheUrl}.xml\""

        if @dry_run
            $logger.info("(Dry run kill) #{cmd}")
            $logger.info("(Dry run truncate) #{killcmd}")
        else
            system(killcmd)
            system(cmd)
            $logger.info("(Excecuting kill->truncate) #{geowebcacheUrl}")
        end
    end

    def seedCache

        geowebcacheUrl = "#{@geowebcache.url}/rest/seed/#{@layer[1]}"
        options = "<seedRequest>"\
            "<name>#{@layer[1]}</name>"\
              "<srs>"\
                "<number>4326</number>"\
                    "</srs>"\
              "<zoomStart>#{@start_zoom}</zoomStart>"\
              "<zoomStop>#{@end_zoom}</zoomStop>"\
              "<format>image/png</format>"\
              "<type>seed</type>"\
              "<threadCount>2</threadCount>"\
           "</seedRequest>"

        cmd = "curl -v -u #{@geowebcache.username}:#{@geowebcache.password} -XPOST -H \"Content-type: text/xml\" -d \"#{options}\" \"#{geowebcacheUrl}.xml\""

        if @dry_run
            $logger.info("(Dry run seed) #{cmd}")
        else
            system(cmd)
            $logger.info("(Excecuting seed) #{geowebcacheUrl}")
        end
    end

    def execute

        if @type == "truncate"
            purgeCache
        else
            purgeCache
            # no seeding if no WMS server url information
            if @layer[0] == nil
                server = (@geoserver.nil?) ? 'UNKNOWN WMS server' : @geoserver
                geonetwork = (@geonetwork.nil?) ? 'UNKNOWN Geonetwork' : @geonetwork
                $logger.error("Layer wont be seeded as it is not known: #{@layer[1]} on #{server} from #{geonetwork}")
            else
                seedCache
            end

        end

        return 1
    end

end
