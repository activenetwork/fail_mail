module FailMail
  class Base
    attr_reader :client

    def initialize client=FailMail.client
      @client = client
    end

    def call *args, &block
      client.call *args, &block
    end

  end
end
