require 'rails_helper'

describe Notification do
  include Factories::Base

  %w(profile message user).each do |method|
    it "should respond to :#{method}" do
      expect(Notification.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @profile = create_user.profile
      @message = "Important update from Renupharm"
      @params  = {
        profile: @profile,
        message: @message
      }
    end

    it "should be valid when all required attributes are supplied" do
      expect(Notification.new(@params)).to be_valid
    end

    it "should be invalid if message is not supplied" do
      expect(Notification.new(@params.merge(message: nil))).not_to be_valid
    end

    it "should be invalid if profile is not supplied" do
      expect(Notification.new(@params.merge(profile: nil))).not_to be_valid
    end
  end
end
