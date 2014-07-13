require 'test_helper'

class SilentFetcherTest < Minitest::Test
  USER_AGENT = "SilentFetcher/#{SilentFetcher::VERSION}"

  def setup
    SilentFetcher.configure do |config|
      config.user_agent = USER_AGENT
    end
  end

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

  def test_fetch_options
    fetch_options = SilentFetcher.send(:fetch_options)

    assert_equal USER_AGENT, fetch_options[:headers]['User-Agent']
  end
end
