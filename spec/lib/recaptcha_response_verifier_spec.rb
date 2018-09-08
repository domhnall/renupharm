require 'rails_helper'
require 'json'
require 'http'
require_relative '../../lib/recaptcha_response_verifier'

describe RecaptchaResponseVerifier do
  before :all do
    @params = {
      site_key: "123456",
      secret_key: "987654"
    }

    @verifier = RecaptchaResponseVerifier.new(@params)
  end

  [ :verify ].each do |method|
    it "should respond to method :#{method}" do
      expect(@verifier).to respond_to method
    end
  end

  describe "initialization" do
    it "should raise an error if the site_key is not supplied" do
      expect{RecaptchaResponseVerifier.new(@params.merge(site_key: nil))}.to raise_error ArgumentError
    end

    it "should raise and error is the secret_key is not supplied" do
      expect{RecaptchaResponseVerifier.new(@params.merge(secret_key: nil))}.to raise_error ArgumentError
    end
  end

  describe "instance method" do
    before :all do
      @recaptcha_success_response = {
        success: true
      }.to_json

      @recaptcha_error_response = {
        success: false
      }.to_json
    end

    describe "#verify" do
      it "should raise an error if the method is passed a nil response to be verified" do
        expect{ @verifier.verify }.to raise_error ArgumentError
      end

      it "should raise an error if the method is passed a blank response to be verified" do
        expect{ @verifier.verify("") }.to raise_error ArgumentError
      end

      it "should return true if the response comes back successful" do
        allow(HTTP).to receive(:post).and_return(@recaptcha_success_response)
        expect(@verifier.verify("dummy")).to be_truthy
      end

      it "should return false if the repsonse comes back unsuccessful" do
        allow(HTTP).to receive(:post).and_return(@recaptcha_error_response)
        expect(@verifier.verify("dummy")).to be_falsey
      end
    end
  end
end
