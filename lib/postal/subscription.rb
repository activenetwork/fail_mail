module Postal
  class Subscription < Base
    attr_reader :list_name, :member_id, :member

    def initialize list_name, member_id, member, client=Postal.client
      super client
      @list_name = list_name
      @member_id = member_id
      @member = member
    end

    def unsubscribe!
      response = call :unsubscribe, unsubscribe_options
      response.body[:unsubscribe_response][:return] == "1"
    end

    private

    def unsubscribe_options
      { message: {
          SimpleMemberStructArrayIn: {
            item: {
              :MemberID => member_id,
              :EmailAddress => member.email,
              :ListName => list_name
            }
          }
        }
      }
    end

  end
end
