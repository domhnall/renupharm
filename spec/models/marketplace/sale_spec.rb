require 'rails_helper'

describe Marketplace::Sale do
  it "should be a kind of Marketplace::Order" do
    expect(Marketplace::Sale.new).to be_a Marketplace::Order
  end
end
