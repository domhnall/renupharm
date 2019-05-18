require 'spec_helper'
require_relative '../../lib/price'

describe Price do
  [ :price_cents,
    :currency_code,
    :currency_symbol,
    :price_major,
    :price_minor,
    :display_price,
    :+,
    :- ].each do |method|
    it "should respond to method :#{method}" do
      expect(Price.new(8999)).to respond_to method
    end
  end

  describe "instantiation" do
    it "should raise an error when no :price_cents supplied" do
      expect{ Price.new }.to raise_error ArgumentError
      expect{ Price.new(nil) }.to raise_error ArgumentError
    end

    it "should assign the :price_cents based on the value supplied" do
      expect(Price.new(999).price_cents).to eq 999
      expect(Price.new("999").price_cents).to eq 999
      expect(Price.new("999.9").price_cents).to eq 999
    end

    it "should set the :currency_code based on the value supplied" do
      expect(Price.new(999, "GBP").currency_code).to eq "GBP"
    end
  end

  describe "instance method" do
    before :all do
      @price = Price.new(9589)
    end

    describe "#currency_symbol" do
      it "should return a String" do
        expect(Price.new(10800).currency_symbol).to be_a String
      end

      it "should return the expected symbol based on :currency_code supplied" do
        expect(Price.new(10800, "EUR").currency_symbol).to eq "€"
        expect(Price.new(10800, "GBP").currency_symbol).to eq "£"
        expect(Price.new(10800, "USD").currency_symbol).to eq "$"
      end

      it "should return € when the :currency_code supplied is not recognized" do
        expect(Price.new(10800, "BRL").currency_symbol).to eq "€"
      end
    end

    describe "#display_price" do
      it "should return a String" do
        expect(@price.display_price).to be_a String
      end

      it "should return the rounded decimal price prefixed the EUR symbol" do
        expect(@price.display_price).to eq "€95.89"
      end
    end

    describe "#price_major" do
      it "should return a String" do
        expect(@price.price_major).to be_a String
      end

      it "should return the integer EUR component of the price" do
        expect(@price.price_major).to eq "95"
      end
    end

    describe "#price_minor" do
      it "should return a String" do
        expect(@price.price_minor).to be_a String
      end

      it "should return the integer cent component of the price" do
        expect(@price.price_minor).to eq "89"
      end
    end

    describe "#+" do
      before :all do
        @price_a = Price.new(100, "EUR")
        @price_b = Price.new(150, "EUR")
        @price_c = Price.new(200, "GBP")
      end

      it "should return an instance of Price" do
        expect(@price_a+@price_b).to be_a Price
      end

      it "should return a Price whose value is the sum of the price cents the combining prices" do
        expect((@price_a+@price_b).price_cents).to eq 250
      end

      it "should return a Price with currency_code equal to the constituent prices" do
        expect((@price_a+@price_b).currency_code).to eq "EUR"
      end

      it "should raise an error when trying to two Price objects with different currency code" do
        expect{ @price_a+@price_c }.to raise_error ArgumentError
      end
    end

    describe "#-" do
      before :all do
        @price_a = Price.new(100, "EUR")
        @price_b = Price.new(150, "EUR")
        @price_c = Price.new(200, "GBP")
      end

      it "should return an instance of Price" do
        expect(@price_b-@price_a).to be_a Price
      end

      it "should return a Price whose value is the sum of the price cents the combining prices" do
        expect((@price_b-@price_a).price_cents).to eq 50
      end

      it "should return a Price with currency_code equal to the constituent prices" do
        expect((@price_b-@price_a).currency_code).to eq "EUR"
      end

      it "should raise an error when trying to two Price objects with different currency code" do
        expect{ @price_c-@price_a }.to raise_error ArgumentError
      end
    end
  end
end
