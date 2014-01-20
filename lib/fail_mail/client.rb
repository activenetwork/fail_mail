require 'savon'

module FailMail
  class Client
    def initialize options={}
      options[:convert_request_keys_to] = :none
      @lyris_client = Savon.client options
    end

    def call *args, &block
      @lyris_client.call *args, &block
    end

    def operations
      @lyris_client.operations
    end

  end
end
