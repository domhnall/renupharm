require 'rails_helper'

describe Adyen::InitialPurchaseRequest do
  subject { Adyen::InitialPurchaseRequest.new }

  [ :build_adyen_params, :valid?, :encrypted_card, :encrypted_card= ].each do |method|
    it "should respond to the instance method '#{method}'" do
      expect(subject).to respond_to method
    end
  end

  describe 'instantiation' do
    let(:params) { {} }
    it 'should correctly initialize attribute :encrypted_card when supplied' do
      expect(Adyen::InitialPurchaseRequest.new(params.merge({encrypted_card: 'test'})).encrypted_card).to eq 'test'
    end

    it 'should set the attribute :encrypted_card to nil when not supplied' do
      expect(Adyen::InitialPurchaseRequest.new({}).encrypted_card).to be_nil
    end
  end

  describe 'instance method' do
    let(:encrypted_card_str) { '<test encrypted card>' }
    let(:params) { { amount_currency: 'USD',
                     amount_value: 2500,
                     merchant_account: 'ExamtimeCOM',
                     reference: SecureRandom.uuid,
                     shopper_reference: 99,
                     encrypted_card: encrypted_card_str } }

    subject { Adyen::InitialPurchaseRequest.new(params) }
    request_key = 'paymentRequest.additionalData.card.encrypted.json'

    describe '#build_adyen_params' do
      let(:generated_hash) { subject.build_adyen_params }

      it "should return a hash with a key of '#{request_key}' and the expected value" do
        expect(generated_hash[request_key]).not_to be_nil
        expect(generated_hash[request_key]).to eq encrypted_card_str
      end
    end

    describe '#valid?' do
      it 'should return true when all mandatory fields are supplied' do
        expect(subject.valid?).to be_truthy
      end

      it 'should return false when :encrypted_card is nil' do
        subject.encrypted_card = nil
        expect(subject.valid?).to be_falsey
      end

      it 'should return false when :encrypted_card is blank' do
        subject.encrypted_card = ''
        expect(subject.valid?).to be_falsey
      end
    end
  end

end
