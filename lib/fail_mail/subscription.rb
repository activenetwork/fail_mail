module FailMail
  class Subscription < Base
    attr_reader :list_name, :member_id, :member

    def initialize list_name, member_id, member, client=FailMail.client
      super client
      @list_name = list_name
      @member_id = member_id
      @member = member
    end

    def unsubscribe!
      response = call :unsubscribe, message: {
        SimpleMemberStructArrayIn: {
          item: {
            MemberID: member_id,
            EmailAddress: member.email,
            ListName: list_name
          }
        }
      }
      response.body[:unsubscribe_response][:return] == "1"
    end

  end
end
