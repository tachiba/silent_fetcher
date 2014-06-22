require 'minitest/autorun'
require 'minitest/pride'
require 'vcr'

require 'nokogiri'
require 'feedjira'

VCR.configure do |c|
  c.cassette_library_dir = 'test/vcr'
  c.hook_into :webmock
end

require 'silent_fetcher'

class SilentFetcherTest < Minitest::Test
  def test_fetch
    VCR.use_cassette('yahoo') do
      assert SilentFetcher.fetch('http://www.yahoo.co.jp/')
    end
  end

  def test_parse_html
    VCR.use_cassette('yahoo') do
      response = SilentFetcher.parse_html('http://www.yahoo.co.jp/')

      assert_instance_of Nokogiri::HTML::Document, response
    end
  end

  def test_parse_feed
    VCR.use_cassette('livedoor_rss') do
      response = SilentFetcher.parse_feed('http://news.livedoor.com/topics/rss/top.xml')

      assert_instance_of Feedjira::Parser::RSS, response
    end
  end
end
