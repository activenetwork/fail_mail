module Postal
  class Member < Base
    attr_reader :email, :name

    def initialize email, name, client=Postal.client
      super client
      @email = email
      @name = name
    end

    def subscribe! list_name
      create_member list_name
    rescue Savon::SOAPFault => exception
      member_id = extract_member_id_from_exception exception
      subscribe_member member_id, list_name if member_id
    end

    def unsubscribe! list_name
      subscription = subscriptions.find { |sub| sub.list_name == list_name }
      subscription.unsubscribe! if subscription
    end

    def subscriptions
      @subscriptions ||= begin
        response = call :select_members_ex, message: {
          FieldsToFetch: { string: %w[MemberID ListName MemberType] },
          FilterCriteriaArray: { string: ["EmailAddress = #{email}", "MemberType = normal"] }
        }
        subscriptions = response.body[:select_members_ex_response][:return][:item]
        subscriptions.shift
        subscriptions.map do |list|
          member_id, list_name, _ = list[:item]
          Postal::Subscription.new list_name, member_id, self
        end
      end
    end

    private

    def create_member list_name
      response = call :create_single_member, message: {
        EmailAddress: email,
        FullName: name,
        ListName: list_name
      }
      member_id = response.body[:create_single_member_response][:return]
      Postal::Subscription.new list_name, member_id, self
    end

    def subscribe_member member_id, list_name
      response = call :update_member_status, message: {
        MemberStatus: 'needs-confirm',
        SimpleMemberStructIn: {
          MemberID: member_id,
          EmailAddress: email,
          ListName: list_name
        }
      }
      if response.body[:update_member_status_response][:return]
        Postal::Subscription.new list_name, member_id, self
      end
    end

    def extract_member_id_from_exception e
      e_list_name, e_email, member_id = e.message.scan(/'([^']*)'/).map &:first
      member_id if e_list_name == list_name && e_email == email
    end

  end
end

