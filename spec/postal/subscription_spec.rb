require 'spec_helper'

describe Postal::Subscription do
  let(:subscription) { Postal::Subscription.new "My List", "123456" }

  describe "initialization" do
    it "initializes with a list name" do
      subscription.list_name.should == "My List"
    end
    it "initializes with a member id" do
      subscription.member_id.should == "123456"
    end

    it "has a client" do
      subscription.client.should be_a Postal::Client
    end
  end
end
