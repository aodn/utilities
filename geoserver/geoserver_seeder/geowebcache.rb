#!/usr/bin/ruby

# TODO This file should be recreated VIA CHEF

class Geowebcache

    attr_reader :url
    attr_reader :username
    attr_reader :password

    def initialize()
        @url = "http://localhost:8888/geowebcache"
        @username = "geowebcache"
        @password = "secured"
    end
end