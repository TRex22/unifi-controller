require 'httparty'
# require 'httparty_with_cookies'
require 'nokogiri'
require 'oj'

require 'unifi-controller/version'
require 'unifi-controller/client'

module UnifiController
  class Error < StandardError; end
end
