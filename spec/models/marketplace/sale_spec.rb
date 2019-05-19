require 'rails_helper'

describe Marketplace::Sale do
  include Factories::Base
  include Factories::Marketplace

  it "should be a kind of Marketplace::Order" do
    expect(Marketplace::Sale.new).to be_a Marketplace::Order
  end

  [ :seller_fee,
    :seller_earning,
    :paid?,
    :cleared?,
    :uncleared?,
    :completed_at ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::Sale.new).to respond_to method
    end
  end

  before :all do
    @admin     = create_admin_user

    @seller    = create_pharmacy(name: "Sammy Seller", email: "sammy@seller.com")
    @seller_b  = create_pharmacy(name: "Second Seller", email: "sammy@second-seller.com")
    @product   = create_product(pharmacy: @seller)
    @listing_a = create_listing(product: @product)
    @listing_b = create_listing(product: @product)
    @listing_c = create_listing(product: @product)
    @listing_d = create_listing(product: @product)
    @listing_e = create_listing(pharmacy: @seller_b)

    @buyer        = create_pharmacy(name: "Billy Buyer", email: "billy@buyer.com")
    @buyer_agent  = create_agent(pharmacy: @buyer)
    @buyer_card   = create_credit_card(pharmacy: @buyer)
    @buy_user     = @buyer_agent.user
    @seller_agent = create_agent(pharmacy: @seller)
    @sell_user    = @seller_agent.user

    @order_a   = create_order({
      agent: @buyer_agent,
      listing: @listing_a,
      state: Marketplace::Order::State::COMPLETED
    }).tap do |order|
      order.history_items.create(user: @buyer_agent.user, from_state: "in_progress", to_state: "placed", created_at: Time.now-35.days)
      order.history_items.create(user: @seller_agent.user, from_state: "placed", to_state: "delivering", created_at: Time.now-33.days)
      order.history_items.create(user: @buyer_agent.user, from_state: "delivering", to_state: "completed", created_at: Time.now-31.days)
    end

    @order_b   = create_order({
      agent: @buyer_agent,
      listing: @listing_b,
      state: Marketplace::Order::State::COMPLETED
    }).tap do |order|
      order.history_items.create(user: @buy_user, from_state: "in_progress", to_state: "placed", created_at: Time.now-32.days)
      order.history_items.create(user: @sell_user, from_state: "placed", to_state: "delivering", created_at: Time.now-30.days)
      order.history_items.create(user: @buy_user, from_state: "delivering", to_state: "completed", created_at: Time.now-28.days)
    end

    @order_c   = create_order({
      agent: @buyer_agent,
      listing: @listing_c,
      state: Marketplace::Order::State::PLACED
    }).tap do |order|
      order.history_items.create(user: @buy_user, from_state: "in_progress", to_state: "placed", created_at: Time.now-32.days)
    end

    @order_d   = create_order({
      agent: @buyer_agent,
      listing: @listing_d,
      state: Marketplace::Order::State::IN_PROGRESS
    })

    @order_e = create_order({
      agent: @buyer_agent,
      listing: @listing_e,
      state: Marketplace::Order::State::COMPLETED
    }).tap do |order|
      order.history_items.create(user: @buy_user, from_state: "in_progress", to_state: "placed", created_at: Time.now-35.days)
      order.history_items.create(user: @sell_user, from_state: "placed", to_state: "delivering", created_at: Time.now-33.days)
      order.history_items.create(user: @buy_user, from_state: "delivering", to_state: "completed", created_at: Time.now-31.days)
    end

    # Add payments to completed orders
    [ @order_a, @order_b, @order_c, @order_e ].each do |order|
      payment = order.create_payment(credit_card: @buyer_card)
      Services::Marketplace::FeesCalculator.new(payment: payment).call
    end
  end

  describe "scope" do
    describe "::for_pharmacy" do
      it "should return orders sold by the pharmacy in COMPLETED state" do
        expect(Marketplace::Sale::for_pharmacy(@seller).map(&:id)).to include @order_a.id
        expect(Marketplace::Sale::for_pharmacy(@seller).map(&:id)).to include @order_b.id
      end

      it "should return orders sold by the pharmacy in PLACED state" do
        expect(Marketplace::Sale::for_pharmacy(@seller).map(&:id)).to include @order_c.id
      end

      it "should not return orders sold by the pharmacy in IN_PROGRESS state" do
        expect(Marketplace::Sale::for_pharmacy(@seller).map(&:id)).not_to include @order_d.id
      end

      it "should not return COMPLETED orders sold by another pharmacy" do
        expect(Marketplace::Sale::for_pharmacy(@seller).map(&:id)).not_to include @order_e.id
        expect(Marketplace::Sale::for_pharmacy(@seller_b).map(&:id)).to include @order_e.id
      end
    end

    describe "seller payouts" do
      before :all do
        @seller.seller_payouts.create!({
          user: @admin,
          orders: [@order_a]
        })

        @seller_b.seller_payouts.create!({
          user: @admin,
          orders: [@order_e]
        })
      end

      describe "::paid_out" do
        it "should return COMPLETED orders which have an associated seller payout" do
          expect(Marketplace::Sale::paid_out.map(&:id)).to include @order_a.id
          expect(Marketplace::Sale::paid_out.map(&:id)).to include @order_e.id
        end

        it "should not return non-COMPLETED orders" do
          expect(Marketplace::Sale::paid_out.map(&:id)).not_to include @order_c.id
          expect(Marketplace::Sale::paid_out.map(&:id)).not_to include @order_d.id
        end

        it "should not return COMPLETED orders without associated seller payout" do
          expect(Marketplace::Sale::paid_out.map(&:id)).not_to include @order_b.id
        end
      end

      describe "::not_paid_out" do
        it "should not return COMPLETED orders which have an associated seller payout" do
          expect(Marketplace::Sale::not_paid_out.map(&:id)).not_to include @order_a.id
          expect(Marketplace::Sale::not_paid_out.map(&:id)).not_to include @order_e.id
        end

        it "should not return non-COMPLETED orders" do
          expect(Marketplace::Sale::not_paid_out.map(&:id)).not_to include @order_d.id
          expect(Marketplace::Sale::not_paid_out.map(&:id)).not_to include @order_c.id
        end

        it "should return COMPLETED orders without associated seller payout" do
          expect(Marketplace::Sale::not_paid_out.map(&:id)).to include @order_b.id
        end
      end
    end

    describe "::cleared" do
      it "should return COMPLETED orders that have been completed for > 30 days" do
        expect(Marketplace::Sale::cleared.map(&:id)).to include @order_a.id
      end

      it "should not return COMPLETED orders that have been completed for < 30 days" do
        expect(Marketplace::Sale::cleared.map(&:id)).not_to include @order_b.id
      end
    end
  end

  describe "instance method" do
    before :all do
      @sale_a = @order_a.becomes(Marketplace::Sale)
      @sale_b = @order_b.becomes(Marketplace::Sale)
      @sale_c = @order_c.becomes(Marketplace::Sale)
      @sale_d = @order_d.becomes(Marketplace::Sale)
      @sale_e = @order_e.becomes(Marketplace::Sale)
    end

    describe "#seller_earning" do
      before :all do
        credit_card = create_credit_card(pharmacy: @buyer)
        payment     = credit_card.payments.create({
          order: @sale_a,
          amount_cents: 9999,
          currency_code: "EUR",
        }).tap do |payment|
          payment.fees.create({
            type: "Marketplace::Accounts::SellerFee",
            amount_cents: 9000,
            currency_code: "EUR"
          })
        end
      end

      it "should return nil for IN_PROGRESS sale" do
        expect(@sale_d.seller_earning).to be_nil
      end

      it "should return a price" do
        expect(@sale_a.seller_earning).to be_a Price
      end

      describe "the Price object returned" do
        it "should have a :currency_code matching the seller payout on the order" do
          expect(@sale_a.seller_earning.currency_code).to eq "EUR"
        end

        it "should have an :price_cents matching the seller payout on the order" do
          expect(@sale_a.seller_earning.price_cents).to be_within(1).of(@sale_a.seller_fee.amount_cents)
        end
      end
    end

    describe "#cleared?" do
      it "should be false if the sale has not been moved to COMPLETED state" do
        expect(@sale_c.cleared?(Date.today+31.days)).to be_falsey
      end

      it "should be false if the sale was moved to COMPLETED state < 30 days ago" do
        expect(@sale_b.cleared?).to be_falsey
      end

      it "should return true if the sale was moved to COMPLETED state > 30 days ago" do
        expect(@sale_a.cleared?).to be_truthy
      end
    end

    describe "#uncleared?" do
      it "should be true if the sale has not been moved to COMPLETED state" do
        expect(@sale_c.uncleared?(Date.today+31.days)).to be_truthy
      end

      it "should be false if the sale was moved to COMPLETED state < 30 days ago" do
        expect(@sale_b.uncleared?).to be_truthy
      end

      it "should return true if the sale was moved to COMPLETED state > 30 days ago" do
        expect(@sale_a.uncleared?).to be_falsey
      end
    end

    describe "#paid?" do
      before :all do
        Marketplace::SellerPayout.create({
          user: @admin,
          pharmacy: @seller,
          orders: [@sale_a]
        })
        @sale_a.reload
      end

      before :each do
        stub_const("Marketplace::Sale::MIN_AGE_FOR_CLEARING_DAYS", 5)
      end

      it "should be true if the sale has an associated payout" do
        expect(@sale_a.paid?).to be_truthy
      end

      it "should be false if the sale has no payout, even if it is cleared" do
        expect(@sale_b.cleared?).to be_truthy
        expect(@sale_b.paid?).to be_falsey
      end
    end

    describe "#completed_at" do
      it "should return nil if the order is not in COMPLETED state" do
        expect(@sale_c.completed_at).to be_nil
      end

      it "should return the timestamp that the order moved into COMPLETED status" do
        expect(@sale_b.completed_at).not_to be_nil
        expect(@sale_b.completed_at).to eq @sale_b.history_items.where(to_state: "completed").first.created_at
      end
    end
  end
end
