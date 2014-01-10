module Postal
  class Subscription < Base
    attr_reader :list_name, :member_id

    def initialize list_name, member_id, client=Postal.client
      super client
      @list_name = list_name
      @member_id = member_id
    end

    #def unsubscribe!
    #end

  end
end
