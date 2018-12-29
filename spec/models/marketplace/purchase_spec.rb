require 'rails_helper'

describe Marketplace::Purchase do
  it "should be a kind of Marketplace::Order" do
    expect(Marketplace::Purchase.new).to be_a Marketplace::Order
  end
end
