require 'rails_helper'

describe Adyen::Error::UrlNotSupplied do
  it 'should be defined' do
    expect(Adyen::Error::UrlNotSupplied).not_to be_nil
  end

  it 'should be a subclass of ArgumentError' do
    expect(Adyen::Error::UrlNotSupplied.new).to be_an ArgumentError
  end
end
