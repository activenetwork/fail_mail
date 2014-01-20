require 'spec_helper'
require 'savon/mock/spec_helper'

describe FailMail::Subscription do
  include Savon::SpecHelper

  before(:all) { savon.mock! }
  after(:all) { savon.unmock! }
  let(:email) { "test@example.com" }
  let(:member_id) { "123456789" }
  let(:list_name) { "my-awesome-list" }
  let(:member) { FailMail::Member.new email, 'Name' }
  let(:subscription) { FailMail::Subscription.new list_name, member_id, member }

  describe "initialization" do
    it "initializes with a list name" do
      subscription.list_name.should == "my-awesome-list"
    end
    it "initializes with a member id" do
      subscription.member_id.should == "123456789"
    end

    it "has a client" do
      subscription.client.should be_a FailMail::Client
    end
  end

  describe "#unsubscribe!" do
    let(:options) { { message: { SimpleMemberStructArrayIn: { item: { MemberID: member_id, EmailAddress: member.email, ListName: list_name } } } } }
    context "when the response is 1" do
      let(:xml_response) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:ns1=\"http://tempuri.org/ns1.xsd\" xmlns:ns=\"http://www.lyris.com/lmapi\"><SOAP-ENV:Body SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><ns:UnsubscribeResponse><return xsi:type=\"xsd:int\">1</return></ns:UnsubscribeResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>" }

      it "is true" do
        savon.expects(:unsubscribe).with(options).returns xml_response
        response = subscription.unsubscribe!
        response.should be_true
      end
    end
    context "when the response is 0" do
      let(:xml_response) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:ns1=\"http://tempuri.org/ns1.xsd\" xmlns:ns=\"http://www.lyris.com/lmapi\"><SOAP-ENV:Body SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><ns:UnsubscribeResponse><return xsi:type=\"xsd:int\">0</return></ns:UnsubscribeResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>" }
      it "is false" do
        savon.expects(:unsubscribe).with(options).returns xml_response
        response = subscription.unsubscribe!
        response.should be_false
      end
    end
  end

end
