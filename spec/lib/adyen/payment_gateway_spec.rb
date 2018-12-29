require 'rails_helper'

describe Adyen::PaymentGateway do
  let(:credentials) { Rails.application.credentials.adyen }
  subject{ Adyen::PaymentGateway.new(credentials) }

  describe 'instantiation' do
    it 'should be possible to create an instance when all mandatory credentials are supplied' do
      expect(Adyen::PaymentGateway.new(credentials)).not_to be_nil
    end

    it 'should raise an error when the :api_username is nil' do
      bad_credentials = credentials.merge({api_username: nil})
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::UsernameNotSupplied
    end

    it 'should raise an error when the :api_username is blank' do
      bad_credentials = credentials.merge({api_username: ''})
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::UsernameNotSupplied
    end

    it 'should raise an error when the :api_username is not supplied' do
      bad_credentials = credentials.except(:api_username)
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::UsernameNotSupplied
    end

    it 'should raise an error when the :api_password is nil' do
      bad_credentials = credentials.merge({api_password: nil})
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::PasswordNotSupplied
    end

    it 'should raise an error when the :api_password is blank' do
      bad_credentials = credentials.merge({api_password: ''})
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::PasswordNotSupplied
    end

    it 'should raise an error when the :api_password is not supplied' do
      bad_credentials = credentials.except(:api_password)
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::PasswordNotSupplied
    end

    it 'should raise an error when the :api_url is nil' do
      bad_credentials = credentials.merge({api_url: nil})
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::UrlNotSupplied
    end

    it 'should raise an error when the :api_url is blank' do
      bad_credentials = credentials.merge({api_url: ''})
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::UrlNotSupplied
    end

    it 'should raise an error when the :api_password is not supplied' do
      bad_credentials = credentials.except(:api_url)
      expect{ Adyen::PaymentGateway.new(bad_credentials) }.to raise_error Adyen::Error::UrlNotSupplied
    end
  end

  [ :purchase, :purchase_subscription, :list_recurring, :disable_recurring, :merchant_account ].each do |method|
    it "should respond to the method '#{method}'" do
      expect(subject).to respond_to method
    end
  end

  describe 'instance methods' do

    let(:params) { { amount_currency: 'USD',
                     amount_value: 2500,
                     merchant_account: 'ExamtimeCOM',
                     reference: SecureRandom.uuid,
                     shopper_reference: 99 } }

    describe '#purchase' do
      let(:initial_request_params) { params.merge( {encrypted_card: '<nonsense>'} ) }
      let(:purchase_request) { Adyen::InitialPurchaseRequest.new(initial_request_params) }
      let(:success_response) { "paymentResult.pspReference=12345&paymentResult.authCode=98765&paymentResult.resultCode=Authorised" }

      before :each do
        @dummy_resource = double('dummy_rest_resource')
        allow(@dummy_resource).to receive(:post).and_return(success_response)
        expect(RestClient::Resource).to receive(:new).and_return(@dummy_resource)
      end

      it 'should raise an error if no request object is supplied' do
        expect{ subject.purchase }.to raise_error Adyen::Error::ApiRequest
      end

      it 'should return a PurchaseResponse instance' do
        result = subject.purchase(purchase_request)
        expect(result).not_to be_nil
        expect(result).to be_a Adyen::PurchaseResponse
      end
    end

    describe '#merchant_account' do
      it "should return the value for merchant_account configured in credentials" do
        expect(Adyen::PaymentGateway.new(credentials.merge(merchant_account: 'DummyAccount')).merchant_account).to eq 'DummyAccount'
      end
    end

    describe '#purchase_subscription' do
      let(:recurring_request_params) { params.merge( {selected_recurring_detail_reference: '90809080'} ) }
      let(:purchase_request) { Adyen::RecurringPurchaseRequest.new(recurring_request_params) }
      let(:success_response) { "paymentResult.pspReference=12345&paymentResult.authCode=98765&paymentResult.resultCode=Authorised" }

      before :each do
        @dummy_resource = double('dummy_rest_resource')
        allow(@dummy_resource).to receive(:post).and_return(success_response)
        expect(RestClient::Resource).to receive(:new).and_return(@dummy_resource)
      end

      it 'should raise an error if no request object is supplied' do
        expect{ subject.purchase_subscription }.to raise_error Adyen::Error::ApiRequest
      end

      it 'should return a PurchaseResponse instance' do
        result = subject.purchase_subscription(purchase_request)
        expect(result).not_to be_nil
        expect(result).to be_a Adyen::PurchaseResponse
      end
    end

    describe '#list_recurring' do
      let(:list_request) { Adyen::ListRecurringRequest.new({merchant_account: 'ExamtimeCOM', shopper_reference: 'jenkins@goconqr.com', shopper_email: 'jenkins@goconqr.com'}) }
      let(:successful_response) { "recurringDetailsResult.shopperReference=jenkins%40examtime.com&recurringDetailsResult.details.0.variant=mc&recurringDetailsResult.details.0.card.number=1111&recurringDetailsResult.details.0.recurringDetailReference=8313988647341975&recurringDetailsResult.details.0.card.expiryMonth=6&recurringDetailsResult.creationDate=2014-04-30T15%3A32%3A14%2B02%3A00&recurringDetailsResult.lastKnownShopperEmail=jenkins%40examtime.com&recurringDetailsResult.details.0.creationDate=2014-04-30T15%3A32%3A14%2B02%3A00&recurringDetailsResult.details.0.card.expiryYear=2016&recurringDetailsResult.details.0.card.holderName=Joe+Tweets" }

      before :each do
        @dummy_resource = double('dummy_rest_resource')
        allow(@dummy_resource).to receive(:post).and_return(successful_response)
        expect(RestClient::Resource).to receive(:new).and_return(@dummy_resource)
      end

      it 'should raise an error if no request object is supplied' do
        expect{ subject.list_recurring }.to raise_error Adyen::Error::ApiRequest
      end

      it 'should submit a request' do
        subject.list_recurring(list_request)
      end

      it 'should return a ListRecurringResponse instance' do
        result = subject.list_recurring(list_request)
        expect(result).not_to be_nil
        expect(result).to be_a Adyen::ListRecurringResponse
      end
    end

    describe '#disable_recurring' do
      let(:disable_request) { Adyen::DisableRecurringRequest.new(merchant_account: 'ExamtimeCOM', shopper_reference: 'jenkins@goconqr.com', recurring_detail_reference: '111111111') }
      let(:success_response) { 'disableResult.response=[detail-successfully-disabled]' }

      before :each do
        @dummy_resource = double('dummy_rest_resource')
        allow(@dummy_resource).to receive(:post).and_return(success_response)
        expect(RestClient::Resource).to receive(:new).and_return(@dummy_resource)
      end

      it 'should raise an error if no request object is supplied' do
        expect{ subject.disable_recurring }.to raise_error Adyen::Error::ApiRequest
      end

      it 'should submit a request' do
        subject.disable_recurring(disable_request)
      end

      it 'should return a Adyen::DisableRecurringResponse instance' do
        result = subject.disable_recurring(disable_request)
        expect(result).not_to be_nil
        expect(result).to be_a Adyen::DisableRecurringResponse
      end
    end
  end
end
