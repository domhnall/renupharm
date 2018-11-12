require 'rails_helper'

describe Adyen::DisableRecurringResponse do

  before :all do
    @response_str = 'disableResult.response=[detail-successfully-disabled]'
  end
  subject { Adyen::DisableRecurringResponse.new(@response_str) }

  [ :response ].each do |method|
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

      it 'should successfully set the :response attribute' do
        expect(subject.response).to eq '[detail-successfully-disabled]'
      end

    end
  end

end
