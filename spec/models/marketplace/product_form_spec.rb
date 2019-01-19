require 'rails_helper'

describe Marketplace::ProductForm do
  [ :name,
    :strength_unit,
    :pack_size_unit,
    :volume_unit,
    :channel_size_unit,
    :strength_meaningful?,
    :strength_required?,
    :pack_size_meaningful?,
    :pack_size_required?,
    :volume_meaningful?,
    :volume_required?,
    :product_identifier_meaningful?,
    :product_identifier_required?,
    :channel_size_meaningful?,
    :channel_size_required? ].each do |method|
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
          expect(Marketplace::ProductForm::for("capsules")).to be_a Marketplace::ProductForm
        end

        it "should return an instance with the correct name, strength_unit and pack_size_unit" do
          expect(Marketplace::ProductForm::for("capsules").name).to eq "Capsule"
          expect(Marketplace::ProductForm::for("capsules").strength_unit).to eq "mg"
          expect(Marketplace::ProductForm::for("capsules").pack_size_unit).to eq "caps"
        end
      end
    end
  end

  describe "instance method" do
    #%w(strength pack_size volume channel_size).each do |property|
    %w(strength).each do |property|
      describe "##{property}_required?" do
        it "should return true for a product form which mandates that #{property} to be captured" do
          prod = Marketplace::ProductForm.new({"name"=>"gel", "#{property}_unit"=>"mg", "#{property}_required"=>true}.symbolize_keys)
          expect(prod.send("#{property}_required?")).to be_truthy
        end

        it "should return false for a product form which does not require #{property} to be captured" do
          prod = Marketplace::ProductForm.new({"name"=>"gel", "#{property}_unit"=>"mg", "#{property}_required"=>false}.symbolize_keys)
          expect(prod.send("#{property}_required?")).to be_falsey
        end
      end

      describe "##{property}_meaningful?" do
        it "should return true for a product form which mandates the #{property}_unit" do
          prod = Marketplace::ProductForm.new({"name"=>"gel", "#{property}_unit"=>"mg"}.symbolize_keys)
          expect(prod.send("#{property}_meaningful?")).to be_truthy
        end

        it "should return false for a product form which does not mandate the #{property}_unit" do
          prod = Marketplace::ProductForm.new({"name"=>"gel", "#{property}_unit"=>nil}.symbolize_keys)
          expect(prod.send("#{property}_meaningful?")).to be_falsey
          prod = Marketplace::ProductForm.new({"name"=>"gel"}.symbolize_keys)
          expect(prod.send("#{property}_meaningful?")).to be_falsey
        end
      end
    end
  end
end
