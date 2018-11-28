require 'rails_helper'

describe Admin::Marketplace::OrdersController do
  include Factories::Marketplace

  before :all do
    @user = create_agent({
      pharmacy: create_pharmacy(name: "Boris' Bargins", email: "boris@bargins.com"),
      user: create_user(email: "bunce@bargins.com")
    }).user

    @selling_pharmacy = create_pharmacy(name: "Sally's", email: "sally@sellers.com").tap do |pharmacy|
      @listing = create_listing(pharmacy: pharmacy)
    end
    @buying_pharmacy = create_pharmacy(name: "McArdle's", email: "harry@mcardles.com").tap do |pharmacy|
      @existing = create_order({
        agent: create_agent(pharmacy: pharmacy, user: create_user(email: "tester@test.com")),
        pharmacy: pharmacy,
        state: Marketplace::Order::State::valid_states.sample
      })
    end

    @update_params = {
      id: @existing.id,
      marketplace_order: {
        id: @existing.id,
        state: "in_progress"
      }
    }
  end

  it_behaves_like "a basic admin controller with :index"
  it_behaves_like "a basic admin controller with :show"
  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :update", Marketplace::Order
end
