require 'minitest/autorun'
require 'webmock/minitest'
require 'logging'

require_relative '../lib/check_geoserver_links'

describe 'check geoserver links' do

  before do
    @checker = GeoserverLinkChecker.new ['http://someurl/geoserver']
  end

  describe 'url construction' do

    it 'get capabilities' do
      @checker.construct_get_capabilities_request_url.
        must_equal 'http://someurl/geoserver/wms?VERSION=1.1.1&REQUEST=GetCapabilities'
    end

    it 'get feature info' do

      @checker.construct_get_feature_info_request_url('my_layer').
        must_equal 'http://someurl/geoserver/wms?LAYERS=my_layer&VERSION=1.1.1&SERVICE=WMS' +
        '&REQUEST=GetFeatureInfo&BBOX=-180,-90,180,90&QUERY_LAYERS=my_layer' +
        '&FEATURE_COUNT=1000&SRS=EPSG:4326&WIDTH=1&HEIGHT=1&X=0&Y=0&INFO_FORMAT=text/html'

    end

    it 'get feature info, layer name with spaces' do
      @checker.construct_get_feature_info_request_url('my layer').
        must_equal 'http://someurl/geoserver/wms?LAYERS=my+layer&VERSION=1.1.1&SERVICE=WMS' +
        '&REQUEST=GetFeatureInfo&BBOX=-180,-90,180,90&QUERY_LAYERS=my+layer' +
        '&FEATURE_COUNT=1000&SRS=EPSG:4326&WIDTH=1&HEIGHT=1&X=0&Y=0&INFO_FORMAT=text/html'
    end

  end

  describe 'get layer names' do

    it 'no layers' do
      stub_request(:get, /.*REQUEST=GetCapabilities.*/).
        to_return(:body => '', :status => 200)

      refute_nil @checker.get_layer_names
      assert_equal 0, @checker.get_layer_names.length
    end

    it 'one layer' do

      response_body = %{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE WMT_MS_Capabilities SYSTEM "http://geoserver.imos.org.au/geoserver/schemas/wms/1.1.1/WMS_MS_Capabilities.dtd">
<WMT_MS_Capabilities version="1.1.1">
  <Capability>
    <Layer>
      <Title>eMII GeoServer WMS</Title>
      <Layer>
        <Name>my_layer</Name>
      </Layer>
    </Layer>
  </Capability>
</WMT_MS_Capabilities>
}
      stub_request(:get, /.*REQUEST=GetCapabilities.*/).
        to_return(:body => response_body, :status => 200)

      assert_equal 1, @checker.get_layer_names.length
      assert_equal 'my_layer', @checker.get_layer_names[0]
    end

    it 'two layers' do

      response_body = %{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE WMT_MS_Capabilities SYSTEM "http://geoserver.imos.org.au/geoserver/schemas/wms/1.1.1/WMS_MS_Capabilities.dtd">
<WMT_MS_Capabilities version="1.1.1">
  <Capability>
    <Layer>
      <Title>eMII GeoServer WMS</Title>
      <Layer>
        <Name>my_layer</Name>
      </Layer>
      <Layer>
        <Name>another_layer</Name>
      </Layer>
    </Layer>
  </Capability>
</WMT_MS_Capabilities>
}
      stub_request(:get, /.*REQUEST=GetCapabilities.*/).
        to_return(:body => response_body, :status => 200)

      assert_equal 2, @checker.get_layer_names.length
      assert_equal 'my_layer', @checker.get_layer_names[0]
      assert_equal 'another_layer', @checker.get_layer_names[1]
    end
  end

  describe 'get links from feature info' do

    it 'set timeout' do
      http = @checker.new_http_for_uri('http://something')
      assert_equal 20, http.read_timeout
    end

    it 'timeout request' do
      stub_request(:get, /.*REQUEST=GetFeatureInfo.*/).to_timeout()

      links = @checker.get_links_for_layer('my_layer')
      assert_equal 1, @checker.timed_out_layers.length
      assert_equal 'my_layer', @checker.timed_out_layers[0]
    end

    it '& in feature info response' do
      response_body = %{

<html>
  <body>
    <a href="http://something?param1=1&param2=2"></a>
  </body>
</html>
}

      stub_request(:get, /.*REQUEST=GetFeatureInfo.*/).to_return(:body => response_body, :status => 200)

      links = @checker.get_links_for_layer('my_layer')
    end

    it 'get links' do

      response_body = %{

<html>
  <head>
    <title>Geoserver GetFeatureInfo output</title>
  </head>
  <body>
    <h3>ABOS Air Sea Flux Stations Moorings</h3>

    <div class="feature">

      <b>LON/LAT</b> 141.98687/-46.77187

      <a href="http://imosmest.emii.org.au/geonetwork/srv/en/metadata.show?uuid=a46f1fe3-2a7c-4086-951e-7351192ec98b"  target="_blank"  rel="external" class="h3" title="http://imosmest.emii.org.au/geonetwork/srv/en/metadata.show?uuid=a46f1fe3-2a7c-4086-951e-7351192ec98b">
        Link to the IMOS metadata record</a>
      <a  rel="external" href="http://thredds.aodn.org.au/thredds/catalog/IMOS/ABOS/ASFS/SOFS/catalog.html" target="_blank" class="h3" >Data on OPeNDAP</a>
      <a  rel="external" href="http://sofs.aodn.org.au/sofs/" target="_blank" class="h3" >Plot of latest data</a>
      <img src="http://geoserver.imos.org.au/portalimages/ABOS/ASFS/SOFS_mooring_small.jpg"/>
      <a class="h3 external" target="_blank" href="http://geoserver.imos.org.au/portalimages/ABOS/ASFS/SOFS_mooring_small.jpg" alt="ABOS Southern Ocean Flux Station Weather Buoy - SOFS image">Image from the deployment</a>

    </div>

  </body>
</html>
}

      stub_request(:get, /.*REQUEST=GetFeatureInfo.*/).to_return(:body => response_body, :status => 200)

      links = @checker.get_links_for_layer('my_layer')
      assert_equal 4, links.length
      assert_equal 'http://imosmest.emii.org.au/geonetwork/srv/en/metadata.show?uuid=a46f1fe3-2a7c-4086-951e-7351192ec98b', links[0]
      assert_equal 'http://sofs.aodn.org.au/sofs/', links[2]

    end
  end

  describe 'links' do

    it 'links are unique' do

      def @checker.get_layer_names
        ['first', 'second']
      end

      def @checker.get_links_for_layer(layer_name)
        if (layer_name == 'first')
          return ['http://aaa', 'http://bbb']
        elsif (layer_name == 'second')
          return ['http://ccc', 'http://aaa']
        end
      end

      # Function returns shuffled links - sort to make test pass consistently.
      assert_equal ['http://aaa', 'http://bbb', 'http://ccc'], @checker.get_links_for_all_layers.sort
    end

    it 'link filtering' do
      assert_equal ['http://asdf', 'https://dsf'],
      @checker.filter_links(['http://asdf', 'https://dsf', 'mailto:jbloggs@mail.com', '#', '', '  '])
    end

    it 'collect link status' do

      stub_request(:head, 'http://goodlink').to_return(:status => 200)
      stub_request(:head, 'http://badlink').to_return(:status => 404)

      def @checker.get_links_for_all_layers
        ['http://goodlink', 'http://badlink']
      end

      link_statuses = @checker.collect_link_statuses(['http://goodlink', 'http://badlink'])

      assert_equal 200, @checker.statuses['http://goodlink']
      assert_equal 404, @checker.statuses['http://badlink']
    end

    it 'query link status connection refused' do
      stub_request(:head, 'http://unreachable').to_raise(Errno::ECONNREFUSED)
      @checker.query_link_status('http://unreachable')
      assert_equal 'Connection refused - Exception from WebMock', @checker.statuses['http://unreachable'].message
    end

    it 'query link status bad URI' do
      uri = 'http://space/in_query_string?uuid= 2a044b8f'
      @checker.query_link_status(uri)
      assert_equal 'bad URI(is not URI?): http://space/in_query_string?uuid= 2a044b8f', @checker.statuses[uri].message
    end

    describe 'link statuses to exit code' do
      it 'empty is ok' do
        assert_equal 0, @checker.statuses_to_exit_code({})
      end

      it 'all 200 is ok' do
        assert_equal 0, @checker.statuses_to_exit_code({ 'first' => 200, 'second' => 200})
      end

      it 'single non 200 is warning' do
        assert_equal 1, @checker.statuses_to_exit_code({ 'first' => 200, 'second' => 404})
        assert_equal 1, @checker.statuses_to_exit_code({ 'first' => 404, 'second' => 200})
      end
    end
  end

  describe 'options' do
    describe 'usage' do
      check_script = 'lib/check_geoserver_links.rb'

      usage = %{Usage: check_geoserver_links <server URL> [options]
    -h, --help                       Display this screen
    -v, --verbose                    Verbose logging
    -r, --reject FILE                Reject links filename
    -o, --output FILE                Output link status filename
    -c, --checked FILE               Checked links filename
    -t, --threads NUM                Threads to use
}

      it 'help' do
        assert_equal usage, `#{check_script} -h url`
        assert_equal 1, $?.exitstatus
      end

      it 'no geoserver url argument' do
        assert_equal usage, `#{check_script}`
        assert_equal 1, $?.exitstatus
      end

      it 'geoserver url as only argument' do
        argv = ['http://theurl']
        @checker = GeoserverLinkChecker.new(argv)

        assert_equal 1, argv.length
        assert_equal 'http://theurl', argv[0]

      end

      it 'geoserver url with other args' do
        argv = ['-v', 'http://theurl']
        @checker = GeoserverLinkChecker.new(argv)

        assert_equal 1, argv.length
        assert_equal 'http://theurl', argv[0]

      end

      it 'default log level' do
        @checker.parse_options(['url'])
        assert_equal Logging::LEVELS['warn'], @checker.logger.level
      end

      it 'verbose log level' do
        @checker.parse_options(['url', '-v'])
        assert_equal Logging::LEVELS['debug'], @checker.logger.level
      end

      it 'reject switch but no filename' do
        assert_raises(OptionParser::MissingArgument) {
          @checker.parse_options(['url', '-r'])
        }
      end

      it 'reject switch' do
        def File.readlines(filename)
          ['first_link', 'second_link']
        end

        @checker.parse_options(['url', '-r', 'the_reject_file'])
        assert_includes @checker.reject_links, /first_link/
        assert_includes @checker.reject_links, /second_link/
      end

      it 'output switch but no filename' do
        assert_raises(OptionParser::MissingArgument) {
          @checker.parse_options(['url', '-o'])
        }
      end

      it 'output switch' do
        @checker.parse_options(['url', '-o', 'outfile'])
        assert_equal 'outfile', @checker.out_filename
      end

      it 'checked links switch' do
        @checker.parse_options(['url', '-c', 'checked_links'])
        assert_equal 'checked_links', @checker.checked_links_filename
      end

      it 'threads switch' do
        @checker.parse_options(['url', '-t', '5'])
        assert_equal 5, @checker.pool.size
      end

    end
  end
end
