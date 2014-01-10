module Postal
  class Base
    attr_reader :client

    def initialize client=Postal.client
      @client = client
    end

    def call *args, &block
      client.call *args, &block
    end

  end
end
