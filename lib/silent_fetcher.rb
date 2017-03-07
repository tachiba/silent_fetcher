require 'timeout'
require 'open-uri'
require 'resolv-replace'
require 'uri'
require 'httparty'
require 'feedjira'

module SilentFetcher; end

require 'silent_fetcher/configuration'
require 'silent_fetcher/version'

module SilentFetcher
  class ExpectedError < StandardError; end

  DEFAULT_CHARSET = 'UTF-8'.freeze
  DEFAULT_RETRY_COUNT = 3
  DEFAULT_TIMEOUT = 60

  EXPECTED_ERRORS = {
    'URI::InvalidURIError'          => [/the scheme http does not accept registry part/, /bad URI/],
    'ArgumentError'                 => [/invalid byte sequence/],
    'SocketError'                   => [/Hostname not known/],
    'RuntimeError'                  => [/HTTP redirection loop/],
    'EOFError'                      => [/end of file reached/],
    'Errno::EHOSTUNREACH'           => [/No route to host/],
    'Errno::ECONNRESET'             => [/Connection reset by peer/],
    'Errno::ECONNREFUSED'           => [/Connection refused/],
    'Errno::ENETUNREACH'            => [/Network is unreachable/],
    'Errno::ETIMEDOUT'              => [],
    'HTTParty::RedirectionTooDeep'  => [],
    'OpenURI::HTTPError'            => [],
    'OpenSSL::SSL::SSLError'        => [/SSL_connect returned=1 errno=0 state=SSLv3/]
  }
  RETRYABLE_ERRORS = [Net::OpenTimeout, Net::ReadTimeout]

  class << self
    attr_accessor :configuration

    def parse_html(url, charset: DEFAULT_CHARSET)
      Nokogiri::HTML(fetch(url), nil, charset)
    end

    def parse_feed(url)
      Feedjira::Feed.parse(
        fetch(url)
      )
    end

    def fetch(url, retry_count: DEFAULT_RETRY_COUNT, allow_no_response: false)
      response = HTTParty.get(url, fetch_options)

      if response.body.size == 0 and not allow_no_response
        raise SilentFetcher::ExpectedError, "response.body.size == 0: #{url}"
      end

      response.body

    rescue *RETRYABLE_ERRORS => e
      if retry_count > 0
        retry_count -= 1
        retry
      else
        raise SilentFetcher::ExpectedError, "#{e.message}: #{url}"
      end

    rescue => e
      class_string = e.class.to_s

      if EXPECTED_ERRORS[class_string] &&
        (EXPECTED_ERRORS[class_string].none? || EXPECTED_ERRORS[class_string].any? {|m| e.message =~ m })
        raise SilentFetcher::ExpectedError, "#{e.class}: #{e.message} by #{url}"
      else
        raise e
      end
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def expected_error_classes
      EXPECTED_ERRORS.keys.map(&:constantize)
    end

    private

    def fetch_options
      {
        headers: {
          'User-Agent' => configuration.user_agent
        },
        timeout: DEFAULT_TIMEOUT
      }
    end
  end
end
