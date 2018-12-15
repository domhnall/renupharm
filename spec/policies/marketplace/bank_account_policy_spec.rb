require 'rails_helper'

describe Marketplace::BankAccountPolicy do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy
    @bank_account = @pharmacy.create_bank_account(
      bank_name: "Suffolk & Watt",
      bic: "BOFIIE2D",
      iban: "IE64BOFI90583812345678"
    )

    @agent = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: 'user@pharmacy.com')
    )
    @user = @agent.user.becomes(Users::Agent)

    @other_pharmacy_agent = create_agent(
      pharmacy: create_pharmacy(name: "Bagg's Pharmacy", email: "billy@baggs.com"),
      user: create_user(email: 'user@otherpharmacy.com')
    )
    @other_pharmacy_user = @other_pharmacy_agent.user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: 'admin@renupharm.ie')
  end

  describe "instantiation" do
    it "should throw an error when first parameter supplied is not of type User" do
      expect{ Marketplace::BankAccountPolicy.new(double("dummy user"), @bank_account) }.to raise_error Pundit::NotAuthorizedError
    end
  end

  describe "instance method" do
    [:show?, :create?, :edit?, :update?].each do |method|
      describe "##{method}" do
        it "should be true where user is an admin" do
          expect(Marketplace::BankAccountPolicy.new(@admin_user, @bank_account).send(method)).to be_truthy
        end

        it "should be true where user is an agent of the pharmacy" do
          expect(Marketplace::BankAccountPolicy.new(@user, @bank_account).send(method)).to be_truthy
        end

        it "should be false where user is not an agent of the pharmacy" do
          expect(Marketplace::BankAccountPolicy.new(@other_pharmacy_user, @bank_account).send(method)).to be_falsey
        end
      end
    end
  end
end
