require 'spec_helper'
require_relative '../../../lib/payment_gateway/authorization_request'

describe PaymentGateway::AuthorizationRequest do

  before :all do
    @user = OpenStruct.new(id: 99)
    @options = {
      user: @user,
      token: "tok_192837465",
    }
  end

  [ :build, :orig_opts ].each do |method|
    it "should respond to the method :#{method}" do
      expect(PaymentGateway::AuthorizationRequest.new(@options)).to respond_to method
    end
  end

  describe "instance method" do
    describe "#build" do
      it "should return a Hash" do
        expect(PaymentGateway::AuthorizationRequest.new(@options).build).to be_a Hash
      end

      describe "hash returned" do
        [:description, :source].each do |key|
          it "should include a key for :#{key}" do
            expect(PaymentGateway::AuthorizationRequest.new(@options).build[key]).not_to be_nil
          end
        end

        it "should include a description composed of user ID concatentated with timestamp" do
          expect(PaymentGateway::AuthorizationRequest.new(@options).build[:description]).to match /^99_\d{10}$/
        end
      end
    end
  end
end
