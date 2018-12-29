require 'rails_helper'

describe AuthenticatedApplicationPolicy do
  include Factories::Base

  describe "instantiation" do
    before :all do
      @user = create_user
      @record = double("dummy record")
    end

    it "should not throw an error when both parameters are supplied" do
      expect{ AuthenticatedApplicationPolicy.new(@user, @record) }.not_to raise_error
    end

    it "should throw an error when user is not supplied" do
      expect{ AuthenticatedApplicationPolicy.new(nil, @record) }.to raise_error Pundit::NotAuthorizedError
    end

    it "should throw an error when first parameter supplied is not of type User" do
      expect{ AuthenticatedApplicationPolicy.new(double("dummy user"), @record) }.to raise_error Pundit::NotAuthorizedError
    end
  end
end
