require 'rails_helper'

describe Users::Agent do
  before :all do
    @params = {
      email: "johnny@bravo.com",
      password: "foobar",
      password_confirmation: "foobar",
      profile_attributes: {
        first_name: "James",
        surname: "Magill",
        telephone: "(01) 283 7188",
        role: Profile::Roles::PHARMACY
      }
    }
  end

  describe "instantiation" do
    it "should be valid when all required fields are supplied" do
      expect(Users::Agent.new(@params)).to be_valid
    end

    it "should be invalid when :email is not supplied" do
      expect(Users::Agent.new(@params.merge(email: ""))).not_to be_valid
      expect(Users::Agent.new(@params.merge(email: nil))).not_to be_valid
    end
  end

  describe "instance method" do
    [ :profile,
      :role,
      :agent,
      :pharmacy,
      :current_order,
      :superintendent? ].each do |method|
      it "should respond to :#{method}" do
        expect(Users::Agent.new(@params)).to respond_to method
      end
    end
  end
end
