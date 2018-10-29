require 'rails_helper'

describe Marketplace::Agent do
  include Factories::Base
  include Factories::Marketplace

  [ :user,
    :pharmacy,
    :orders,
    :current_order,
    :full_name,
    :telephone,
    :email ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Agent.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @user = create_user(email: "daniel@sandymount.ie")
      @pharmacy = create_pharmacy
      @params = {
        user_id: @user.id,
        marketplace_pharmacy_id: @pharmacy.id
      }
    end

    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Agent.new(@params)).to be_valid
    end

    it "should be invalid when :marketplace_pharmacy_id is not supplied" do
      expect(Marketplace::Agent.new(@params.merge(marketplace_pharmacy_id: nil))).not_to be_valid
    end

    it "should be invalid when :user_id is not supplied" do
      expect(Marketplace::Agent.new(@params.merge(user_id: nil))).not_to be_valid
    end
  end
end
