module Postal
  class Member < Base
    attr_reader :email

    def initialize email, client=Postal.client
      super client
      @email = email
    end

    def subscriptions
      response = call :select_members_ex, subscriptions_options
      subscriptions = response.body[:select_members_ex_response][:return][:item]
      subscriptions.shift
      subscriptions.map do |list|
        member_id, list_name, _ = list[:item]
        Postal::Subscription.new list_name, member_id
      end
    end

    private

    def subscriptions_options
      { :message => {
          FieldsToFetch: { string: %w[MemberID ListName MemberType] },
          FilterCriteriaArray: { string: ["EmailAddress = #{email}", "MemberType = normal"] }
      } }
    end

  end
end

