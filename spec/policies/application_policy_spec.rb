require 'rails_helper'

describe ApplicationPolicy do
  before :all do
    @user = double("dummy user")
    @record = double("dummy record")
    @policy = ApplicationPolicy.new(@user, @record)
  end

  [:user,
   :record,
   :index?,
   :show?,
   :create?,
   :new?,
   :update?,
   :edit?,
   :destroy?].each do |method|
    it "should respond to ##{method}" do
      expect(@policy).to respond_to method
    end
  end

  describe "instantiation" do
    it "should set the user to the first argument passed" do
      expect(ApplicationPolicy.new(@user, @record).user).to eq @user
    end

    it "should be valid when no user is passed" do
      expect(ApplicationPolicy.new(nil, @record).user).to be_nil
    end

    it "should set the record to the second argument passed" do
      expect(ApplicationPolicy.new(@user, @record).record).to eq @record
    end

    it "should be valid when no record is passed" do
      expect(ApplicationPolicy.new(@user, nil).record).to be_nil
    end
  end

  describe "instance method" do
    [ :index?,
      :show?,
      :create?,
      :update?,
      :destroy? ].each do |method|
      describe "##{method}" do
        it "should return false" do
          expect(@policy.send(method)).to be_falsey
        end
      end
    end

    describe "#new?" do
      it "should return the same value as #create?" do
        expect(@policy).to receive(:create?).and_return("fish")
        expect(@policy.new?).to eq "fish"
      end
    end

    describe "#edit?" do
      it "should return the same value as #update?" do
        expect(@policy).to receive(:update?).and_return("supper")
        expect(@policy.edit?).to eq "supper"
      end
    end
  end
end
