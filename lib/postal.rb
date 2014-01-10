require "postal/version"
require "postal/configurable"
require "postal/base"
require "postal/client"
require "postal/member"
require "postal/subscription"
require "postal/list"

# Configuration Example
#
# Postal.configure do |config|
#   config.wsdl = "http://example.com/?wsdl"
#   config.basic_auth = ["username", "password"]
# end

module Postal
  extend Postal::Configurable

  def self.client
    Postal::Client.new options
  end

  def self.options
    options = {}
    Postal::Configurable.keys.each do |key|
      options[key] = send key
    end
    options
  end

end
