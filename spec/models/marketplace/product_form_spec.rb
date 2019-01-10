require 'rails_helper'

describe Marketplace::ProductForm do
  [ :name,
    :strength_unit,
    :pack_size_unit ].each do |method|
    it "instance should respond to the method '#{method}'" do
      expect(Marketplace::ProductForm.new).to respond_to method
    end
  end

  (Marketplace::ProductForm::PERMITTED | [:for]).each do |class_method|
    it "class should respond to the method '#{class_method}'" do
      expect(Marketplace::ProductForm).to respond_to class_method
    end
  end

  describe "class method" do
    describe "::for" do
      it "should return nil if argument is not a supported form" do
        expect(Marketplace::ProductForm::for("rubbish")).to be_nil
      end

      describe "when argument is a supported form" do
        it "should return a Marketplace::ProductForm instance" do
          expect(Marketplace::ProductForm::for("hard_capsules")).to be_a Marketplace::ProductForm
        end

        it "should return an instance with the correct name, strength_unit and pack_size_unit" do
          expect(Marketplace::ProductForm::for("hard_capsules").name).to eq "Hard capsules"
          expect(Marketplace::ProductForm::for("hard_capsules").strength_unit).to eq "mg"
          expect(Marketplace::ProductForm::for("hard_capsules").pack_size_unit).to eq "caps"
        end
      end
    end
  end
end
