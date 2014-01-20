require "fail_mail/version"
require "fail_mail/configurable"
require "fail_mail/base"
require "fail_mail/client"
require "fail_mail/member"
require "fail_mail/subscription"
require "fail_mail/list"

# Configuration Example
#
# FailMail.configure do |config|
#   config.wsdl = "http://example.com/?wsdl"
#   config.basic_auth = ["username", "password"]
# end

module FailMail
  extend FailMail::Configurable

  def self.client
    FailMail::Client.new options
  end

  def self.options
    options = {}
    FailMail::Configurable.keys.each do |key|
      options[key] = send key
    end
    options
  end

end
