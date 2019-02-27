require 'spec_helper'
require_relative '../../../app/models/services'
require_relative '../../../app/models/services/response'

describe Services::Response do
  [ :errors,
    :status,
    :success?,
    :failure? ].each do |method|
    it "should respond to method :#{method}" do
      expect(Services::Response.new).to respond_to method
    end
  end

  describe "initialization" do
    before :each do
      @arr = ["What a load of", "Such a pile of"]
      @response = Services::Response.new(errors: @arr)
    end

    it "should track :errors appended to the array" do
      expect(@response.errors.last).to eq "Such a pile of"
      @arr << "How much"
      expect(@response.errors.last).to eq "How much"
    end
  end
end
