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
