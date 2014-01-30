require 'minitest/autorun'
require 'webmock/minitest'
require 'logging'

require_relative '../lib/cat_geoserver_links'

describe 'cat geoserver links' do

  before do
    @catter = GeoserverLinkCatter.new ['http://someurl/geoserver']
  end

  describe 'url construction' do

    it 'get capabilities' do
      @catter.construct_get_capabilities_request_url.
        must_equal 'http://someurl/geoserver/wms?VERSION=1.1.1&REQUEST=GetCapabilities'
    end

    it 'get feature info' do

      @catter.construct_get_feature_info_request_url('my_layer').
        must_equal 'http://someurl/geoserver/wms?LAYERS=my_layer&VERSION=1.1.1&SERVICE=WMS' +
        '&REQUEST=GetFeatureInfo&BBOX=-180,-90,180,90&QUERY_LAYERS=my_layer' +
        '&FEATURE_COUNT=1000&SRS=EPSG:4326&WIDTH=1&HEIGHT=1&X=0&Y=0&INFO_FORMAT=text/html'

    end

    it 'get feature info, layer name with spaces' do
      @catter.construct_get_feature_info_request_url('my layer').
        must_equal 'http://someurl/geoserver/wms?LAYERS=my+layer&VERSION=1.1.1&SERVICE=WMS' +
        '&REQUEST=GetFeatureInfo&BBOX=-180,-90,180,90&QUERY_LAYERS=my+layer' +
        '&FEATURE_COUNT=1000&SRS=EPSG:4326&WIDTH=1&HEIGHT=1&X=0&Y=0&INFO_FORMAT=text/html'
    end

  end

  describe 'get layer names' do

    it 'no layers' do
      stub_request(:get, /.*REQUEST=GetCapabilities.*/).
        to_return(:body => '', :status => 200)

      refute_nil @catter.get_layer_names
      assert_equal 0, @catter.get_layer_names.length
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

      assert_equal 1, @catter.get_layer_names.length
      assert_equal 'my_layer', @catter.get_layer_names[0]
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

      assert_equal 2, @catter.get_layer_names.length
      assert_equal 'my_layer', @catter.get_layer_names[0]
      assert_equal 'another_layer', @catter.get_layer_names[1]
    end
  end

  describe 'get links from feature info' do

    it 'set timeout' do
      http = @catter.new_http_for_uri('http://something')
      assert_equal 20, http.read_timeout
    end

    it 'timeout request' do
      stub_request(:get, /.*REQUEST=GetFeatureInfo.*/).to_timeout()

      links = @catter.get_links_for_wfs_layer('my_layer')
      assert_equal 1, @catter.timed_out_layers.length
      assert_equal 'my_layer', @catter.timed_out_layers[0]
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

      links = @catter.get_links_for_wfs_layer('my_layer')
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

      links = @catter.get_links_for_wfs_layer('my_layer')
      assert_equal 4, links.length
      assert_equal 'http://imosmest.emii.org.au/geonetwork/srv/en/metadata.show?uuid=a46f1fe3-2a7c-4086-951e-7351192ec98b', links[0]
      assert_equal 'http://sofs.aodn.org.au/sofs/', links[2]

    end
  end

  describe 'links' do

    it 'links are unique' do

      def @catter.get_layer_names
        ['first', 'second']
      end

      def @catter.get_links_for_wfs_layer(layer_name)
        if (layer_name == 'first')
          return ['http://aaa', 'http://bbb']
        elsif (layer_name == 'second')
          return ['http://ccc', 'http://aaa']
        end
      end

      assert_equal ['http://aaa', 'http://bbb', 'http://ccc'], @catter.get_links_for_all_layers
    end
  end

  describe 'options' do
    describe 'usage' do
      check_script = 'lib/cat_geoserver_links.rb'

      usage = %{Usage: cat_geoserver_links <server URL> [options]
    -h, --help                       Display this screen
    -v, --verbose                    Verbose logging
        --wms                        WMS links only
        --layers                     Layer names only
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
        @catter = GeoserverLinkCatter.new(argv)

        assert_equal 1, argv.length
        assert_equal 'http://theurl', argv[0]

      end

      it 'geoserver url with other args' do
        argv = ['-v', 'http://theurl']
        @catter = GeoserverLinkCatter.new(argv)

        assert_equal 1, argv.length
        assert_equal 'http://theurl', argv[0]

      end

      it 'default log level' do
        @catter.parse_options(['url'])
        assert_equal Logging::LEVELS['warn'], @catter.logger.level
      end

      it 'verbose log level' do
        @catter.parse_options(['url', '-v'])
        assert_equal Logging::LEVELS['debug'], @catter.logger.level
      end

    end
  end
end
