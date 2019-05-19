require 'rails_helper'

describe Marketplace::Account do
  include Factories::Marketplace

  before :all do
    @seller       = create_pharmacy(name: "Sammy Seller", email: "sammy@seller.com")
    @seller_agent = create_agent(pharmacy: @seller)
    @product      = create_product(pharmacy: @seller)
    @listing_a    = create_listing(product: @product)
    @listing_b    = create_listing(product: @product)
    @listing_c    = create_listing(product: @product)
    @listing_d    = create_listing(product: @product)

    @buyer        = create_pharmacy(name: "Billy Buyer", email: "billy@buyer.com").tap do |pharm|
      @credit_card = create_credit_card(pharmacy: pharm)
    end
    @buyer_agent  = create_agent(pharmacy: @buyer)

    # Set up cleared orders (i.e. completed > 30 days)
    @cleared_order_a   = create_completed_order({ agent: @buyer_agent, listing: @listing_a })
    @cleared_order_b   = create_completed_order({ agent: @buyer_agent, listing: @listing_b })
    [ @cleared_order_a, @cleared_order_b ].each do |order|
      order.history_items.where(to_state: "completed").first.update_column(:created_at, Time.now-40.days)
    end

    # Set up uncleared orders (i.e. completed < 30 days)
    @uncleared_order_c = create_completed_order({ agent: @buyer_agent, listing: @listing_c })
    @uncleared_order_d = create_completed_order({ agent: @buyer_agent, listing: @listing_d })
    [ @uncleared_order_c, @uncleared_order_d ].each do |order|
      order.history_items.where(to_state: "completed").first.update_column(:created_at, Time.now-20.days)
    end

    # Ensure all completed orders have appropriate payout fees set up
    [ @cleared_order_a, @cleared_order_b, @uncleared_order_c, @uncleared_order_d ].each_with_index do |order, i|
      order.create_payment(credit_card: @credit_card, amount_cents: (i+1)*4000, currency_code: "EUR")
      Services::Marketplace::FeesCalculator.new(payment: order.reload.payment).call
      order.reload
    end

    @completed_ids = [@cleared_order_a, @cleared_order_b, @uncleared_order_c, @uncleared_order_d].map(&:id)

    # Set up historical payouts for seller
    @payout_1 = create_seller_payout(pharmacy: @seller, orders: [@cleared_order_a])
    @payout_2 = create_seller_payout(pharmacy: @seller, orders: [@cleared_order_b])
  end

  [ :pharmacy,
    :sales,
    :purchases,
    :sales_payable,
    :sales_uncleared,
    :payouts_to_date,
    :balance,
    :uncleared_earnings,
    :total_payouts_to_date,
    :display_balance,
    :display_uncleared_earnings,
    :display_total_payouts_to_date
  ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::Account.new(pharmacy: @buyer)).to respond_to method
    end
  end

  describe "instantiation" do
    it "should raise an exception where pharmacy is not supplied" do
      expect{ Marketplace::Account.new }.to raise_error ArgumentError
    end

    it "should raise an exception where pharmacy is not an instance of Marketplace::Pharmacy" do
      expect{ Marketplace::Account.new(pharmacy: "some pharmacy") }.to raise_error ArgumentError
    end

    it "should complete without errors when pharmacy is supplied" do
      expect(Marketplace::Account.new(pharmacy: @buyer)).to be_a Marketplace::Account
      expect(Marketplace::Account.new(pharmacy: @buyer).pharmacy).to eq @buyer
    end
  end

  describe "instance method" do
    describe "#balance" do
      it "should return a Price instance" do
        expect(Marketplace::Account.new(pharmacy: @seller).balance).to be_a Price
      end

      it "should represent the combined seller earnings of any sales that have been cleared but have not been paid out" do
        expect(Marketplace::Account.new(pharmacy: @seller).balance.price_cents).to eq 11_400
        expect(Marketplace::Account.new(pharmacy: @seller).balance.currency_code).to eq "EUR"
      end

      it "should return a zero price where there have been no cleared sales" do
        expect(Marketplace::Account.new(pharmacy: @buyer).balance.price_cents).to eq 0
      end
    end

    describe "#uncleared_earnings" do
      it "should return a Price instance" do
        expect(Marketplace::Account.new(pharmacy: @seller).uncleared_earnings).to be_a Price
      end

      it "should represent the combined seller earnings of any sales that are unpaid, but have not yet been cleared" do
        expect(Marketplace::Account.new(pharmacy: @seller).uncleared_earnings.price_cents).to eq 26_600
        expect(Marketplace::Account.new(pharmacy: @seller).uncleared_earnings.currency_code).to eq "EUR"
      end

      it "should return a zero price where there are no uncleared sales" do
        expect(Marketplace::Account.new(pharmacy: @buyer).uncleared_earnings.price_cents).to eq 0
      end
    end

    describe "#total_payouts_to_date" do
      it "should return a Price instance" do
        expect(Marketplace::Account.new(pharmacy: @seller).total_payouts_to_date).to be_a Price
      end

      it "should represent the combined value of all payouts already processed" do
        total_payout_cents = @cleared_order_a.becomes(Marketplace::Sale).seller_fee.amount_cents +
          @cleared_order_b.becomes(Marketplace::Sale).seller_fee.amount_cents
        expect(Marketplace::Account.new(pharmacy: @seller).total_payouts_to_date.price_cents).to eq total_payout_cents
        expect(Marketplace::Account.new(pharmacy: @seller).total_payouts_to_date.currency_code).to eq "EUR"
      end

      it "should return a zero price where there have been no payouts" do
        expect(Marketplace::Account.new(pharmacy: @buyer).total_payouts_to_date.price_cents).to eq 0
      end
    end

    [ :balance,
      :uncleared_earnings,
      :total_payouts_to_date ].each do |method|

      describe "##{method}" do
        it "should return a String" do
          expect(Marketplace::Account.new(pharmacy: @buyer).send("display_#{method}".to_sym)).to be_a String
        end

        it "should represent the display price of :#{method}" do
          acc = Marketplace::Account.new(pharmacy: @seller)
          expect(acc.send("display_#{method}".to_sym)).to eq acc.send(method).display_price
        end
      end
    end

    describe "#sales" do
      it "should be empty where the pharmacy doesn't have any completed sales" do
        expect(Marketplace::Account.new(pharmacy: @buyer).sales.map(&:id)).to be_empty
      end

      it "should return any completed sales for the pharmacy" do
        expect(Marketplace::Account.new(pharmacy: @seller).sales.map(&:id)).to match_array @completed_ids
      end
    end

    describe "#purchases" do
      it "should be empty where the pharmacy doesn't have any completed purchases" do
        expect(Marketplace::Account.new(pharmacy: @seller).purchases.map(&:id)).to be_empty
      end

      it "should return any completed purchases for the pharmacy" do
        expect(Marketplace::Account.new(pharmacy: @buyer).purchases.map(&:id)).to match_array @completed_ids
      end
    end
  end
end
