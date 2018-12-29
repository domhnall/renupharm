require 'rails_helper'

describe Adyen::ListRecurringRequest do
  subject { Adyen::ListRecurringRequest.new }

  it 'should define a non-empty array of REQUEST_FIELDS' do
    expect(Adyen::ListRecurringRequest::REQUEST_ATTRIBUTES).not_to be_nil
    expect(Adyen::ListRecurringRequest::REQUEST_ATTRIBUTES).to be_an Array
    expect(Adyen::ListRecurringRequest::REQUEST_ATTRIBUTES).not_to be_empty
  end

  it 'should define a non-empty hash of ADYEN_REQUEST_KEYS' do
    expect(Adyen::ListRecurringRequest::ADYEN_REQUEST_KEYS).not_to be_nil
    expect(Adyen::ListRecurringRequest::ADYEN_REQUEST_KEYS).to be_a Hash
    expect(Adyen::ListRecurringRequest::ADYEN_REQUEST_KEYS).not_to be_empty
  end

  Adyen::ListRecurringRequest::REQUEST_ATTRIBUTES.each do |method|
    it "should respond to the instance method '#{method}'" do
      expect(subject).to respond_to method
    end

    setter_method = "#{method}=".to_sym
    it "should respond to the instance method '#{setter_method}'" do
      expect(subject).to respond_to setter_method
    end
  end

  [ :build_adyen_params, :valid? ].each do |method|
    it "should respond to the instance method '#{method}'" do
      expect(subject).to respond_to method
    end
  end

  describe 'instantiation' do
    let(:params) { {} }
    Adyen::ListRecurringRequest::REQUEST_ATTRIBUTES.each do |attr|
      it "should correctly initialize attribute :#{attr} when supplied" do
        expect(Adyen::ListRecurringRequest.new(params.merge({attr => 'test'})).send(attr)).to eq 'test'
      end

      unless [ :action, :recurring_contract ].include?(attr)
        it "should set the attribute :#{attr} to nil when not supplied" do
          expect(Adyen::ListRecurringRequest.new({}).send(attr)).to be_nil
        end
      end
    end

    it "should set the :action attribute to 'Recurring.listRecurringDetails' if not supplied" do
      expect(Adyen::ListRecurringRequest.new({}).action).to eq 'Recurring.listRecurringDetails'
    end

    it "should set the :recurring_contract attribute to 'RECURRING' if not supplied" do
      expect(Adyen::ListRecurringRequest.new({}).recurring_contract).to eq 'RECURRING'
    end
  end

  describe 'instance method' do
    let(:params) { { merchant_account: 'ExamtimeCOM',
                     shopper_reference: 99 } }
    subject { Adyen::ListRecurringRequest.new(params) }

    describe '#build_adyen_params' do
      let(:generated_hash) { subject.build_adyen_params }

      Adyen::ListRecurringRequest::ADYEN_REQUEST_KEYS.each do |attr,key|
        it "should return a hash with a key of #{key} and the expected value" do
          subject.send("#{attr}=", 'test')
          expect(generated_hash[key]).not_to be_nil
          expect(generated_hash[key]).to eq 'test'
        end
      end

      # Optional params should be excluded if not supplied
      Adyen::PurchaseRequest::ADYEN_REQUEST_KEYS.select{|k,v| [:shopper_email].include?(k)}.each do |attr, key|
        it "should not include '#{attr}' if the corresponding attribute is nil" do
          subject.send("#{attr}=", nil)
          expect(generated_hash.keys).not_to include key
        end
      end
    end

    describe '#valid?' do
      it "should return true if all params pass some basic validation checks" do
        expect(subject.valid?).to be_truthy
      end

      [ :action, :merchant_account, :recurring_contract, :shopper_reference ].each do |mandatory_attr|
        it "should return false if #{mandatory_attr} not supplied" do
          subject.send("#{mandatory_attr}=", nil)
          expect(subject.valid?).to be_falsey
        end
      end
    end
  end
end
