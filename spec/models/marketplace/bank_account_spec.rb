require 'rails_helper'

describe Marketplace::BankAccount do
  include Factories::Marketplace

  [ :bank_name,
    :bic,
    :iban ].each do |method|
    it "should respond to method :#{method}" do
      expect(Marketplace::BankAccount.new).to respond_to method
    end
  end
  before :all do
    @pharmacy = create_pharmacy
    @params = {
      marketplace_pharmacy_id: @pharmacy.id,
      bic: "BOFIIE2D",
      iban: "IE64BOFI90583812345678"
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Marketplace::BankAccount.new(@params)).to be_valid
    end

    it "should be invalid when marketplace pharmacy is not defined" do
      expect(Marketplace::BankAccount.new(@params.merge(marketplace_pharmacy_id: nil))).not_to be_valid
    end

    it "should be invalid when BIC is not defined" do
      expect(Marketplace::BankAccount.new(@params.merge(bic: nil))).not_to be_valid
    end

    it "should be invalid when IBAN is not defined" do
      expect(Marketplace::BankAccount.new(@params.merge(iban: nil))).not_to be_valid
    end

    describe "BIC" do
      it "should be valid if BIC is 8 characters long" do
        expect(Marketplace::BankAccount.new(@params.merge(bic: "123456 78"))).to be_valid
      end

      it "should be valid if BIC is 11 characters long" do
        expect(Marketplace::BankAccount.new(@params.merge(bic: "1234 567890A"))).to be_valid
      end

      it "should be invalid if BIC is not 8 or 11 characters long" do
        expect(Marketplace::BankAccount.new(@params.merge(bic: "1234567890"))).not_to be_valid
        expect(Marketplace::BankAccount.new(@params.merge(bic: "1234567890AB"))).not_to be_valid
      end
    end

    describe "IBAN" do
      it "should be invalid if IBAN does not start with two characters" do
        expect(Marketplace::BankAccount.new(@params.merge(iban: "I64BOFI90583812345678"))).not_to be_valid
      end

      it "should be invalid if IBAN does not have two digits in postions 3 and 4" do
        expect(Marketplace::BankAccount.new(@params.merge(iban: "IE6ABOFI90583812345678"))).not_to be_valid
      end

      it "should be invalid if IBAN exceeds 34 characters" do
        expect(Marketplace::BankAccount.new(@params.merge(iban: "IE6ABOFI90583812345678IE64BOFI90583812345678"))).not_to be_valid
      end
    end
  end

  describe "instance method" do
    before :each do
      @bank_account = Marketplace::BankAccount.new(@params)
    end

    describe "#iban=" do
      it "should set the value supplied" do
        @bank_account.iban = "Somerubbish"
        expect(@bank_account.iban).to eq "Somerubbish"
      end

      it "should set the value supplied" do
        @bank_account.iban = "Some rubbish with spaces"
        expect(@bank_account.iban).to eq "Somerubbishwithspaces"
      end
    end

    describe "#bic=" do
      it "should set the value supplied" do
        @bank_account.bic = "Somerubbish"
        expect(@bank_account.bic).to eq "Somerubbish"
      end

      it "should set the value supplied" do
        @bank_account.bic = "Some rubbish with spaces"
        expect(@bank_account.bic).to eq "Somerubbishwithspaces"
      end
    end
  end
end
