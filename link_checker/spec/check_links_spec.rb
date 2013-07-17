require 'minitest/autorun'
require 'webmock/minitest'
require 'logging'

require_relative '../lib/check_links'

describe 'check links' do

  before do
    @checker = LinkChecker.new ['http://someurl/geoserver']
  end

  describe 'links' do

    it 'collect link status' do

      stub_request(:head, 'http://goodlink').to_return(:status => 200)
      stub_request(:head, 'http://badlink').to_return(:status => 404)

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

  end

  describe 'options' do
    describe 'usage' do
      check_script = 'lib/check_links.rb'

      usage = %{Usage: check_links [FILE]... [options]
    -h, --help                       Display this screen
    -v, --verbose                    Verbose logging
    -t, --threads NUM                Threads to use
}

      it 'help' do
        assert_equal usage, `#{check_script} -h url`
        assert_equal 1, $?.exitstatus
      end

      it 'default log level' do
        @checker.parse_options(['url'])
        assert_equal Logging::LEVELS['warn'], @checker.logger.level
      end

      it 'verbose log level' do
        @checker.parse_options(['url', '-v'])
        assert_equal Logging::LEVELS['debug'], @checker.logger.level
      end

      it 'threads switch' do
        @checker.parse_options(['url', '-t', '5'])
        assert_equal 5, @checker.pool.size
      end

    end
  end
end
