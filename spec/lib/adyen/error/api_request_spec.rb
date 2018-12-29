require 'rails_helper'

describe Adyen::Error::ApiRequest do
  it 'should be defined' do
    expect(Adyen::Error::ApiRequest).not_to be_nil
  end

  it 'should be a subclass of StandardError' do
    expect(Adyen::Error::ApiRequest.new).to be_a StandardError
  end

  it 'should not be a subclass of ArgumentError' do
    expect(Adyen::Error::ApiRequest.new).not_to be_an ArgumentError
  end
end
