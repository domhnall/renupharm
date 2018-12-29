require 'rails_helper'

describe Adyen::Error::PasswordNotSupplied do
  it 'should be defined' do
    expect(Adyen::Error::PasswordNotSupplied).not_to be_nil
  end

  it 'should be a subclass of ArgumentError' do
    expect(Adyen::Error::PasswordNotSupplied.new).to be_an ArgumentError
  end
end
