require 'spec_helper'
require 'savon/mock/spec_helper'

describe Postal::Member do
  include Savon::SpecHelper

  before(:all) { savon.mock! }
  after(:all) { savon.unmock! }
  let(:email) { 'chris.t.ferguson@gmail.com' }
  let(:member) { Postal::Member.new email }

  describe "initialization" do
    it "initializes with an email" do
      member.email.should == email
    end

    it "has a client" do
      member.client.should be_a Postal::Client
    end
  end

  describe "#subscriptions" do
    let(:options) { { :message => { FieldsToFetch: { string: %w[MemberID ListName MemberType] }, FilterCriteriaArray: { string: ["EmailAddress = #{email}", "MemberType = normal"] } } } }
    let(:xml_response) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:SOAP-ENC=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:ns1=\"http://tempuri.org/ns1.xsd\" xmlns:ns=\"http://www.lyris.com/lmapi\"><SOAP-ENV:Body SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><ns:SelectMembersExResponse><return xsi:type=\"SOAP-ENC:Array\" SOAP-ENC:arrayType=\"xsd:string[][2]\"><item xsi:type=\"SOAP-ENC:Array\" SOAP-ENC:arrayType=\"xsd:string[3]\"><item xsi:type=\"xsd:string\">memberid</item><item xsi:type=\"xsd:string\">listname</item><item xsi:type=\"xsd:string\">membertype</item></item><item xsi:type=\"SOAP-ENC:Array\" SOAP-ENC:arrayType=\"xsd:string[3]\"><item xsi:type=\"xsd:string\">114376836</item><item xsi:type=\"xsd:string\">active-trainer2</item><item xsi:type=\"xsd:string\">normal</item></item></return></ns:SelectMembersExResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>" }

    it "returns an array of Subscriptions" do
      savon.expects(:select_members_ex).with(options).returns xml_response
      member.subscriptions.first.should be_a Postal::Subscription
    end
  end

end

