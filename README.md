# SilentFetcher

SilentFetcher aims to reduce that programmers write common error handling several times.

It ignores errors which are commonly handled (and often be ignored) when fetching URL and has also an ability to parse HTML/RSS, using [nokogiri](https://github.com/sparklemotion/nokogiri) and [feedjira](https://github.com/feedjira/feedjira).

## Installation

Add this line to your application's Gemfile:

    gem 'silent_fetcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install silent_fetcher

## Usage

```rb
# You have to configure before using this.
SilentFetcher.configure do |config|
  config.user_agent = "YOUR AGENT NAME"
end

url = "https://news.ycombinator.com/rss"

response_body = SilentFetcher.fetch(url)
#=> <rss version=\"2.0\"><channel><title>Hacker News</title><link>https: ...

response = SilentFetcher.parse_feed(url)
#=> #<Feedjira::Parser::RSS:0x007ffe7c1d7dd8 @version="2.0", @title="Hacker News", @url="https://news.ycombinator.com/", ...

url = "https://www.google.co.jp"

response = SilentFetcher.parse_html(url)
#=> #<Nokogiri::HTML::Document:0x3ff86d00cbc0 name="document" children=[#<Nokogiri::XML::DTD:0x3ff86d00c0e4 name="html">, ...
```

## Contributing

1. Fork it ( https://github.com/tachiba/silent_fetcher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
