module Postal
  module Configurable

    def self.keys
      [:wsdl, :basic_auth]
    end

    attr_accessor *keys

    def configure
      yield self
      self
    end

  end
end
