require 'rails_helper'

describe Notification do
  %w(profile message).each do |method|
    it "should respond to :#{method}" do
      expect(Notification.new).to respond_to method
    end
  end
end
