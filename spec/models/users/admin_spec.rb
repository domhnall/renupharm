require 'rails_helper'

describe Users::Admin do
  before :all do
    @params = {
      email: "dev@renupharm.ie",
      password: "foobar",
      password_confirmation: "foobar",
      profile_attributes: {
        first_name: "Domhnall",
        surname: "Murphy",
        telephone: "(01) 283 7188",
        role: Profile::Roles::ADMIN
      }
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Users::Admin.new(@params)).to be_valid
    end

    it "should be invalid when :email is not supplied" do
      expect(Users::Admin.new(@params.merge(email: ""))).not_to be_valid
      expect(Users::Admin.new(@params.merge(email: nil))).not_to be_valid
    end
  end

  describe "instance method" do
    [ :profile,
      :role,
      :seller_payouts ].each do |method|
      it "should respond to :#{method}" do
        expect(Users::Admin.new(@params)).to respond_to method
      end
    end
  end
end
