require 'rails_helper'

describe Adyen::RecurringPurchaseRequest do
  subject { Adyen::RecurringPurchaseRequest.new }

  [ :build_adyen_params, :valid?, :selected_recurring_detail_reference,
    :selected_recurring_detail_reference=, :shopper_interaction, :shopper_interaction= ].each do |method|
    it "should respond to the instance method '#{method}'" do
      expect(subject).to respond_to method
    end
  end

  describe 'instantiation' do
    let(:params) { {} }
    [ :selected_recurring_detail_reference, :shopper_interaction].each do |attr|
      it "should correctly initialize attribute :#{attr} when supplied" do
        expect(Adyen::RecurringPurchaseRequest.new(params.merge({attr => 'test'})).send(attr)).to eq 'test'
      end
    end

    it 'should set :selected_recurring_detail_reference to nil when not supplied' do
      expect(Adyen::RecurringPurchaseRequest.new({}).selected_recurring_detail_reference).to be_nil
    end

    it "should set :shopper_interaction to 'ContAuth' when not supplied" do
      expect(Adyen::RecurringPurchaseRequest.new({}).shopper_interaction).to eq 'ContAuth'
    end
  end

  describe 'instance method' do
    let(:selected_recurring_detail_ref) { '90809080' }
    let(:params) { { amount_currency: 'USD',
                     amount_value: 2500,
                     merchant_account: 'ExamtimeCOM',
                     reference: SecureRandom.uuid,
                     shopper_reference: 99,
                     selected_recurring_detail_reference: selected_recurring_detail_ref,
                     shopper_interaction: 'ContAuth' } }

    subject { Adyen::RecurringPurchaseRequest.new(params) }
    recurring_detail_ref_key = 'paymentRequest.selectedRecurringDetailReference'
    shopper_interaction_key = 'paymentRequest.shopperInteraction'

    describe '#build_adyen_params' do
      let(:generated_hash) { subject.build_adyen_params }

      it "should return a hash with a key of '#{recurring_detail_ref_key}' and the expected value" do
        expect(generated_hash[recurring_detail_ref_key]).not_to be_nil
        expect(generated_hash[recurring_detail_ref_key]).to eq selected_recurring_detail_ref
      end

      it "should return a hash with a key of '#{shopper_interaction_key}' and the expected value" do
        expect(generated_hash[shopper_interaction_key]).not_to be_nil
        expect(generated_hash[shopper_interaction_key]).to eq 'ContAuth'
      end
    end

    describe '#valid?' do
      it 'should return true when all mandatory fields are supplied' do
        expect(subject.valid?).to be_truthy
      end

      it 'should return false when :selected_recurring_detail_reference is nil' do
        subject.selected_recurring_detail_reference = nil
        expect(subject.valid?).to be_falsey
      end

      describe ':shopper_interaction' do
        [ 'ContAuth', 'Ecommerce' ].each do |valid_interaction|
          it "should return true when :shopper_interaction is set to '#{valid_interaction}'" do
            subject.shopper_interaction = valid_interaction
            expect(subject.valid?).to be_truthy
          end
        end

        [ '', nil, 'Coulomb', 'gravitational', 'rubbish' ].each do |invalid_interaction|
          it "should return false when :shopper_interaction is set to '#{invalid_interaction}'" do
            subject.shopper_interaction = invalid_interaction
            expect(subject.valid?).to be_falsey
          end
        end
      end
    end
  end

end
