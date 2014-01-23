require 'spec_helper'
require 'savon/mock/spec_helper'

describe FailMail::Member do
  include Savon::SpecHelper

  before(:all) { savon.mock! }
  after(:all) { savon.unmock! }
  let(:email) { 'test@example.com' }
  let(:name) { 'Example User' }
  let(:member) { FailMail::Member.new email, name }

  describe "initialization" do
    it "initializes with an email" do
      member.email.should == email
    end

    it "initializes with an name" do
      member.name.should == name
    end

    it "has a client" do
      member.client.should be_a FailMail::Client
    end
  end

  describe "#subscribe!" do
    let(:email) { "test@example.com" }
    let(:list_name) { "my-awesome-list" }
    let(:member_id) { "123456789" }

    context "when the member is not already on the list" do
      let(:xml_response) { %Q|<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://tempuri.org/ns1.xsd" xmlns:ns="http://www.lyris.com/lmapi"><SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><ns:CreateSingleMemberResponse><return xsi:type="xsd:int">#{member_id}</return></ns:CreateSingleMemberResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>| }
      let(:options) { { message: { EmailAddress: email, FullName: name, ListName: list_name } } }

      it "calls create_single_member and returns something" do
        savon.expects(:create_single_member).with(options).returns xml_response
        member.subscribe!(list_name).member_id.should == member_id
      end
    end

    context "when the member is already on the list" do
      let(:create_xml_response) { %Q|<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://tempuri.org/ns1.xsd" xmlns:ns="http://www.lyris.com/lmapi"><SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><SOAP-ENV:Fault><faultcode>SOAP-ENV:Server</faultcode><faultstring xsi:type="xsd:string">A member already exists on list '#{list_name}' with email address '#{email}', with ID '#{member_id}'</faultstring></SOAP-ENV:Fault></SOAP-ENV:Body></SOAP-ENV:Envelope>| }
      let(:update_xml_response) { %Q|<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://tempuri.org/ns1.xsd" xmlns:ns="http://www.lyris.com/lmapi"><SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><ns:UpdateMemberStatusResponse><return xsi:type="xsd:boolean">true</return></ns:UpdateMemberStatusResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>| }
      let(:create_options) { { message: { EmailAddress: email, FullName: name, ListName: list_name } } }
      let(:update_options) { { message: { MemberStatus: 'needs-confirm', SimpleMemberStructIn: { MemberID: member_id, EmailAddress: email, ListName: list_name } } } }

      it "calls both create_single_member and update_member_status which returns true" do
        savon.expects(:create_single_member).with(create_options).returns create_xml_response
        savon.expects(:update_member_status).with(update_options).returns update_xml_response
        member.subscribe!(list_name).member_id.should == member_id
      end
    end

  end

  describe "#unsubscribe!" do
    let(:subscription) { FailMail::Subscription.new 'example_list', '1234', 'normal', member }

    it "calls subscriptions" do
      subscription.stub :unsubscribe!
      member.should_receive(:subscriptions).and_return [subscription]
      member.unsubscribe! 'example_list'
    end

    it "calls unsubscribe! on the subscription" do
      subscription.should_receive :unsubscribe!
      member.stub subscriptions: [subscription]
      member.unsubscribe! 'example_list'
    end
  end

  describe "#subscriptions" do
    let(:options) { { message: { FieldsToFetch: { string: %w[MemberID ListName MemberType] }, FilterCriteriaArray: { string: ["EmailAddress = #{email}"] } } } }
    let(:xml_response) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:ns1=\"http://tempuri.org/ns1.xsd\" xmlns:ns=\"http://www.lyris.com/lmapi\"><SOAP-ENV:Body SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><ns:SelectMembersExResponse><return xsi:type=\"SOAP-ENC:Array\" SOAP-ENC:arrayType=\"xsd:string[][2]\"><item xsi:type=\"SOAP-ENC:Array\" SOAP-ENC:arrayType=\"xsd:string[3]\"><item xsi:type=\"xsd:string\">memberid</item><item xsi:type=\"xsd:string\">listname</item><item xsi:type=\"xsd:string\">membertype</item></item><item xsi:type=\"SOAP-ENC:Array\" SOAP-ENC:arrayType=\"xsd:string[3]\"><item xsi:type=\"xsd:string\">114376836</item><item xsi:type=\"xsd:string\">active-trainer2</item><item xsi:type=\"xsd:string\">normal</item></item></return></ns:SelectMembersExResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>" }

    it "returns an array of Subscriptions" do
      savon.expects(:select_members_ex).with(options).returns xml_response
      member.subscriptions.first.should be_a FailMail::Subscription
    end

    context "when the member has no subscriptions" do
      let(:xml_response) { %Q{<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns1="http://tempuri.org/ns1.xsd" xmlns:ns="http://www.lyris.com/lmapi"><SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><ns:SelectMembersExResponse></ns:SelectMembersExResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>} }
      it "returns an empty array" do
        savon.expects(:select_members_ex).with(options).returns xml_response
        member.subscriptions.should be_empty
      end
    end

  end

end

