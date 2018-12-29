require 'rails_helper'

describe Adyen::Error::UsernameNotSupplied do
  it 'should be defined' do
    expect(Adyen::Error::UsernameNotSupplied).not_to be_nil
  end

  it 'should be a subclass of ArgumentError' do
    expect(Adyen::Error::UsernameNotSupplied.new).to be_an ArgumentError
  end
end
