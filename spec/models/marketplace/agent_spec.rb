require 'rails_helper'

describe Marketplace::Agent do
  include Factories::Base
  include Factories::Marketplace

  [ :user,
    :pharmacy,
    :orders,
    :current_order,
    :full_name,
    :first_name,
    :surname,
    :telephone,
    :email ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Agent.new).to respond_to method
    end
  end

  before :all do
    @user = create_user(email: "daniel@sandymount.ie")
    @pharmacy = create_pharmacy
    @params = {
      user_id: @user.id,
      marketplace_pharmacy_id: @pharmacy.id,
      superintendent: true
    }
  end

  describe "instantiation" do
    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Agent.new(@params)).to be_valid
    end

    it "should be invalid when :marketplace_pharmacy_id is not supplied" do
      expect(Marketplace::Agent.new(@params.merge(marketplace_pharmacy_id: nil))).not_to be_valid
    end

    it "should be invalid when :user_id is not supplied" do
      expect(Marketplace::Agent.new(@params.merge(user_id: nil))).not_to be_valid
    end

    it "should be invalid if this is the first agent for pharmacy and is not the superintendent" do
      expect(Marketplace::Agent.new(@params.merge(superintendent: false))).not_to be_valid
    end

    it "should be invalid if marked as superintendent but there is an existing superintendent for the pharmacy" do
      create_agent(pharmacy: @pharmacy, user: create_user, superintendent: true)
      expect(Marketplace::Agent.new(@params.merge(superintendent: true))).not_to be_valid
    end
  end

  describe "#current_order" do
    before :all do
      @agent = Marketplace::Agent.create!(user_id: @user.id, marketplace_pharmacy_id: @pharmacy.id, superintendent: true)
      product = create_product(pharmacy: create_pharmacy(name: 'MacGregors', email: 'conor@macgregors.com'))
      @completed_order = create_order(
        agent: @agent,
        state: Marketplace::Order::State::COMPLETED,
        listing: create_listing(product: product)
      )
      @current_order = create_order(
        agent: @agent,
        state: Marketplace::Order::State::IN_PROGRESS,
        listing: create_listing(product: product)
      )
    end

    it "should return a single in-progress order for the agent" do
      expect(@agent.reload.current_order.id).to eq @current_order.id
    end

    it "should return nil where no in-progress orders exist" do
      @current_order.update_column(:state, Marketplace::Order::State::COMPLETED)
      expect(@agent.reload.current_order).to be_nil
    end
  end
end
