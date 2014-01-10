require 'spec_helper'

describe Postal do

  describe '.client' do
    it "returns a Postal::Client" do
      Postal.client.should be_a Postal::Client
    end
  end

  describe '.configure' do
    Postal::Configurable.keys.each do |key|
      it "sets the #{key}" do
        Postal.configure do |config|
          config.send "#{key}=", key
        end
        Postal.send(key).should == key
      end
    end
  end

end
