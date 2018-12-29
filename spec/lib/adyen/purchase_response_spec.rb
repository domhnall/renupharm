require 'rails_helper'

describe Adyen::PurchaseResponse do
  let(:success_str) { "paymentResult.pspReference=12345&paymentResult.authCode=98765&paymentResult.resultCode=Authorised" }
  let(:refused_str) { "paymentResult.pspReference=12345&paymentResult.refusalReason=Nonsense&paymentResult.resultCode=Refused" }
  let(:refused_response) { Adyen::PurchaseResponse.new(refused_str) }
  subject { Adyen::PurchaseResponse.new(success_str) }

  [ :psp_reference, :auth_code, :result_code, :refusal_reason, :authorised?, :refused?, :error?, :received? ].each do |method|
    it "should respond to the instance method '#{method}'" do
      expect(subject).to respond_to method
    end
  end

  describe 'instantiation' do
    describe 'successful response' do
      it 'should be successfully instantiated from a properly formatted string' do
        expect(subject).not_to be_nil
      end

      it 'should successfully set the :psp_reference attribute' do
        expect(subject.psp_reference).to eq '12345'
      end

      it 'should successfully set the :auth_code attribute' do
        expect(subject.auth_code).to eq '98765'
      end

      it 'should successfully set the :result_code attribute' do
        expect(subject.result_code).to eq 'Authorised'
      end

      it 'should not set the :refusal_reason attribute' do
        expect(subject.refusal_reason).to be_nil
      end
    end

    describe 'refused response' do
      it 'should not set the :auth_code attribute' do
        expect(refused_response.auth_code).to be_nil
      end

      it 'should successfully set the :refusal_reason attribute' do
        expect(refused_response.refusal_reason).to eq 'Nonsense'
      end
    end

    it 'should raise an error when instantiated with a nil response string' do
      expect{ Adyen::PurchaseResponse.new(nil) }.to raise_error Adyen::Error::ApiResponse
    end

    it 'should raise an error when instantiated with a blank response string' do
      expect{ Adyen::PurchaseResponse.new('') }.to raise_error Adyen::Error::ApiResponse
    end

    it 'should raise an error when the string does not contain a :result_code' do
      expect{ Adyen::PurchaseResponse.new('paymentResult.pspReference=12345') }.to raise_error Adyen::Error::ApiResponse
    end

    it 'should raise an error when the string does not contain a :psp_reference' do
      expect{ Adyen::PurchaseResponse.new('paymentResult.resultCode=Authorised') }.to raise_error Adyen::Error::ApiResponse
    end

    it 'should raise an error when the :result_code is not one of the expected values' do
      expect{ Adyen::PurchaseResponse.new('paymentResult.pspReference=12345&paymentResult.resultCode=Unexpected') }.to raise_error Adyen::Error::ApiResponse
    end
  end

  describe 'instance method' do
    describe '#authorised?' do
      it 'should return true if the response was authorised' do
        expect(subject.authorised?).to be_truthy
      end
    end
  end
end
