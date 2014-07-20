require 'timeout'
require 'open-uri'
require 'resolv-replace'
require 'uri'
require 'httparty'
require 'feedjira'

module SilentFetcher; end

require 'silent_fetcher/configuration'

module SilentFetcher
  class ExpectedError < StandardError; end

  DEFAULT_CHARSET = 'UTF-8'.freeze
  DEFAULT_RETRY_COUNT = 3
  DEFAULT_TIMEOUT = 60

  EXPECTED_ERRORS = [
      URI::InvalidURIError, ArgumentError, SocketError,
      Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH,
      HTTParty::RedirectionTooDeep, EOFError
  ]
  EXPECTED_ERROR_MESSAGES = {
      'URI::InvalidURIError'  => [/the scheme http does not accept registry part/, /bad URI/],
      'ArgumentError'         => [/invalid byte sequence/],
      'SocketError'           => [/Hostname not known/],
      'Errno::EHOSTUNREACH'   => [/No route to host/],
      'Errno::ECONNRESET'     => [/Connection reset by peer/],
      'Errno::ECONNREFUSED'   => [/Connection refused/],
      'Errno::ENETUNREACH'    => [/Network is unreachable/],
      'EOFError'              => [/end of file reached/]
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

    rescue *EXPECTED_ERRORS => e
      if EXPECTED_ERROR_MESSAGES[e.class.to_s] &&
          EXPECTED_ERROR_MESSAGES[e.class.to_s].any? {|m| e.message =~ m }
        raise SilentFetcher::ExpectedError, "#{e.message}: #{url}"
      else
        raise e, "#{e.message}: #{url}"
      end
    end

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    protected
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
