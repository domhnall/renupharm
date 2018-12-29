require 'rails_helper'

describe Adyen::ListRecurringResponse do
  before :all do
    @response_str = 'recurringDetailsResult.shopperReference=99&'\
      'recurringDetailsResult.creationDate=2014-04-30T15%3A32%3A14%2B02%3A00&'\
      'recurringDetailsResult.lastKnownShopperEmail=jenkins%40goconqr.com&'\
      'recurringDetailsResult.details.0.variant=mc&'\
      'recurringDetailsResult.details.0.recurringDetailReference=8313988647341975&'\
      'recurringDetailsResult.details.0.creationDate=2014-04-30T15%3A32%3A14%2B02%3A00&'\
      'recurringDetailsResult.details.0.card.number=1111&'\
      'recurringDetailsResult.details.0.card.expiryMonth=6&'\
      'recurringDetailsResult.details.0.card.expiryYear=2016&'\
      'recurringDetailsResult.details.0.card.holderName=Joe+Tweets&'\
      'recurringDetailsResult.details.1.variant=mc&'\
      'recurringDetailsResult.details.1.recurringDetailReference=8313988647341976&'\
      'recurringDetailsResult.details.1.creationDate=2014-05-01T15%3A32%3A14%2B02%3A00&'\
      'recurringDetailsResult.details.1.card.number=2222&'\
      'recurringDetailsResult.details.1.card.expiryMonth=8&'\
      'recurringDetailsResult.details.1.card.expiryYear=2018&'\
      'recurringDetailsResult.details.1.card.holderName=Pat+Bleets'
  end
  subject { Adyen::ListRecurringResponse.new(@response_str) }

  [ :shopper_reference, :creation_date, :last_known_shopper_email, :details ].each do |method|
    it "should respond to the instance method '#{method}'" do
      expect(subject).to respond_to method
    end

    setter_method = "#{method}=".to_sym
    it "should respond to the instance method '#{setter_method}'" do
      expect(subject).to respond_to setter_method
    end
  end

  describe 'instantiation' do
    describe 'successful response' do
      it 'should be successfully instantiated from a properly formatted string' do
        expect(subject).not_to be_nil
      end

      it 'should successfully set the :shopper_reference attribute' do
        expect(subject.shopper_reference).to eq '99'
      end

      it 'should successfully set the :creation_date attribute' do
        expect(subject.creation_date).to eq '2014-04-30T15:32:14+02:00'
      end

      it 'should successfully set the :last_known_shopper_email attribute' do
        expect(subject.last_known_shopper_email).to eq 'jenkins@goconqr.com'
      end

      it 'should successfully set the :details attribute' do
        expect(subject.details).not_to be_nil
      end

      describe 'details' do
        let(:card_1) { subject.details[0] }
        let(:card_2) { subject.details[1] }

        it 'should have a size of two' do
          expect(subject.details.size).to eq 2
        end

        it 'should be composed of two instances of Adyen::ListRecurringResponse::Detail' do
          expect(card_1).to be_a Adyen::ListRecurringResponse::Detail
          expect(card_2).to be_a Adyen::ListRecurringResponse::Detail
        end

        it 'should successfully set the :variant on both cards' do
          expect(card_1.variant).to eq 'mc'
          expect(card_2.variant).to eq 'mc'
        end

        it 'should successfully set the :creation_date on both cards' do
          expect(card_1.creation_date).to eq '2014-04-30T15:32:14+02:00'
          expect(card_2.creation_date).to eq '2014-05-01T15:32:14+02:00'
        end

        it 'should successfully set the :recurring_detail_reference on both cards' do
          expect(card_1.recurring_detail_reference).to eq '8313988647341975'
          expect(card_2.recurring_detail_reference).to eq '8313988647341976'
        end

        it 'should successfully set the :card_number on both cards' do
          expect(card_1.card_number).to eq '1111'
          expect(card_2.card_number).to eq '2222'
        end

        it 'should successfully set the :card_expiry_month on both cards' do
          expect(card_1.card_expiry_month).to eq '6'
          expect(card_2.card_expiry_month).to eq '8'
        end

        it 'should successfully set the :card_expiry_year on both cards' do
          expect(card_1.card_expiry_year).to eq '2016'
          expect(card_2.card_expiry_year).to eq '2018'
        end

        it 'should successfully set the :card_holder_name on both cards' do
          expect(card_1.card_holder_name).to eq 'Joe Tweets'
          expect(card_2.card_holder_name).to eq 'Pat Bleets'
        end
      end
    end
  end
end
