require 'rails_helper'

describe Adyen::DisableRecurringRequest do
  subject { Adyen::DisableRecurringRequest.new }

  it 'should define a non-empty array of REQUEST_FIELDS' do
    expect(Adyen::DisableRecurringRequest::REQUEST_ATTRIBUTES).not_to be_nil
    expect(Adyen::DisableRecurringRequest::REQUEST_ATTRIBUTES).to be_an Array
    expect(Adyen::DisableRecurringRequest::REQUEST_ATTRIBUTES).not_to be_empty
  end

  it 'should define a non-empty hash of ADYEN_REQUEST_KEYS' do
    expect(Adyen::DisableRecurringRequest::ADYEN_REQUEST_KEYS).not_to be_nil
    expect(Adyen::DisableRecurringRequest::ADYEN_REQUEST_KEYS).to be_a Hash
    expect(Adyen::DisableRecurringRequest::ADYEN_REQUEST_KEYS).not_to be_empty
  end

  Adyen::DisableRecurringRequest::REQUEST_ATTRIBUTES.each do |method|
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
    Adyen::DisableRecurringRequest::REQUEST_ATTRIBUTES.each do |attr|
      it "should correctly initialize attribute :#{attr} when supplied" do
        expect(Adyen::DisableRecurringRequest.new(params.merge({attr => 'test'})).send(attr)).to eq 'test'
      end

      unless [ :action ].include?(attr)
        it "should set the attribute :#{attr} to nil when not supplied" do
          expect(Adyen::DisableRecurringRequest.new({}).send(attr)).to be_nil
        end
      end
    end

    it "should set the :action attribute to 'Recurring.disable' if not supplied" do
      expect(Adyen::DisableRecurringRequest.new({}).action).to eq 'Recurring.disable'
    end
  end

  describe 'instance method' do
    let(:params) { { merchant_account: 'ExamtimeCOM',
                     shopper_reference: '99',
                     recurring_detail_reference: '90809080' } }
    subject { Adyen::DisableRecurringRequest.new(params) }

    describe '#build_adyen_params' do
      let(:generated_hash) { subject.build_adyen_params }

      Adyen::DisableRecurringRequest::ADYEN_REQUEST_KEYS.each do |attr,key|
        it "should return a hash with a key of #{key} and the expected value" do
          subject.send("#{attr}=", 'test')
          expect(generated_hash[key]).not_to be_nil
          expect(generated_hash[key]).to eq 'test'
        end
      end
    end

    describe '#valid?' do
      it "should return true if all params pass some basic validation checks" do
        expect(subject.valid?).to be_truthy
      end

      [ :action, :merchant_account, :shopper_reference, :recurring_detail_reference ].each do |mandatory_attr|
        it "should return false if #{mandatory_attr} not supplied" do
          subject.send("#{mandatory_attr}=", nil)
          expect(subject.valid?).to be_falsey
        end
      end
    end
  end

end
