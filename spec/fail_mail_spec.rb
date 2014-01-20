require 'spec_helper'

describe FailMail do

  describe '.client' do
    it "returns a FailMail::Client" do
      FailMail.client.should be_a FailMail::Client
    end
  end

  describe '.configure' do
    FailMail::Configurable.keys.each do |key|
      it "sets the #{key}" do
        FailMail.configure do |config|
          config.send "#{key}=", key
        end
        FailMail.send(key).should == key
      end
    end
  end

end
