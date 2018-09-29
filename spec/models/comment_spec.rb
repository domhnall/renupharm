require 'rails_helper'

describe Comment do
  include Factories

  before :all do
    @admin = create_user(email: 'admin@renupharm.ie')
    @pharmacy = Sales::Pharmacy.create({
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4, Irishtown",
      address_3: "Dublin 4",
      telephone: "(01) 283 7188",
    })

    @params = {
      body: "Hey this is my comment",
      commentable_type: "Sales::Pharmacy",
      commentable_id: @pharmacy.id,
      user: @admin
    }

    @comment = Comment.new(@params)
  end

  [:commentable].each do |method|
    it "should respond to :#{method}" do
      expect(@comment).to respond_to method
    end
  end

  describe "instantiation" do
    it "should be valid when supplied with all mandatory fields" do
      expect(Comment.new(@params)).to be_valid
    end

    it "should be valid when :commentable association is defined rather than separate (:type,:id)" do
      expect(Comment.new(@params.merge(commentable_id: nil, commentable_type: nil, commentable: @pharmacy))).to be_valid
    end

    it "should be invalid when user is not defined" do
      expect(Comment.new(user: nil)).not_to be_valid
    end

    it "should be invalid without a :commentable_type" do
      expect(Comment.new(@params.merge(commentable_type: nil))).not_to be_valid
    end

    it "should be invalid without a :commentable_id" do
      expect(Comment.new(@params.merge(commentable_id: nil))).not_to be_valid
    end

    it "should be invalid when the :body is nil" do
      expect(Comment.new(@params.merge(body: nil))).not_to be_valid
    end

    it "should be invalid when the :body is blank" do
      expect(Comment.new(@params.merge(body: ""))).not_to be_valid
    end

    it "should be invalid when the :body exceeds 1000 characters in length" do
      expect(Comment.new(@params.merge(body: "a"*999))).to be_valid
      expect(Comment.new(@params.merge(body: "a"*1001))).not_to be_valid
    end
  end
end
