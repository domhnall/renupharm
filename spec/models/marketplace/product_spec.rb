require 'rails_helper'

describe Marketplace::Product do
  include Factories::Base
  include Factories::Marketplace

  [ :name,
    :active_ingredient,
    :form,
    :strength,
    :pack_size,
    :manufacturer,
    :pharmacy,
    :pharmacy_name,
    :pharmacy_description,
    :pharmacy_address,
    :listings,
    :product_form,
    :product_form_name,
    :strength_unit,
    :pack_size_unit,
    :display_strength,
    :display_pack_size ].each do |method|
    it "should respond to :#{method}" do
      expect(Marketplace::Product.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @pharmacy = create_pharmacy
      @params = {
        pharmacy: @pharmacy,
        name: "Paracetomol",
        active_ingredient: "stuff",
        form: "hard_capsules",
        pack_size: "40",
        strength: "110",
        active: true
      }
    end

    it "should be valid when all mandatory attributes are supplied" do
      expect(Marketplace::Product.new(@params)).to be_valid
    end

    it "should be valid when :pharmacy is not supplied" do
      expect(Marketplace::Product.new(@params.merge(pharmacy: nil, marketplace_pharmacy_id: nil))).to be_valid
    end

    it "should be invalid when :name is not supplied" do
      expect(Marketplace::Product.new(@params.merge(name: nil))).not_to be_valid
    end

    it "should be invalid when :active_ingredient is not supplied" do
      expect(Marketplace::Product.new(@params.merge(active_ingredient: nil))).not_to be_valid
    end

    it "should be invalid when :form is not supplied" do
      expect(Marketplace::Product.new(@params.merge(form: nil))).not_to be_valid
    end

    it "should be invalid when :strength is not supplied" do
      expect(Marketplace::Product.new(@params.merge(strength: nil))).not_to be_valid
    end

    it "should be invalid when :pack_size is not supplied" do
      expect(Marketplace::Product.new(@params.merge(pack_size: nil))).not_to be_valid
    end

    it "should be invalid when :strength is not a number" do
      expect(Marketplace::Product.new(@params.merge(strength: "5mg"))).not_to be_valid
      expect(Marketplace::Product.new(@params.merge(strength: "5"))).to be_valid
      expect(Marketplace::Product.new(@params.merge(strength: "5.0mg"))).not_to be_valid
      expect(Marketplace::Product.new(@params.merge(strength: "5.0"))).to be_valid
    end

    it "should be invalid when :pack_size is not a number" do
      expect(Marketplace::Product.new(@params.merge(pack_size: "40caps"))).not_to be_valid
      expect(Marketplace::Product.new(@params.merge(pack_size: "40"))).to be_valid
      expect(Marketplace::Product.new(@params.merge(pack_size: "250.0ml"))).not_to be_valid
      expect(Marketplace::Product.new(@params.merge(pack_size: "250.0"))).to be_valid
    end

    [:name, :active_ingredient].each do |attr|
      describe "#{attr} length" do
        it "should be invalid when :#{attr} is less than 3 characters" do
          expect(Marketplace::Product.new(@params.merge(attr => "a"*2))).not_to be_valid
          expect(Marketplace::Product.new(@params.merge(attr => "a"*3))).to be_valid
        end

        it "should be invalid when :#{attr} is greater than 255 characters" do
          expect(Marketplace::Product.new(@params.merge(attr => "a"*255))).to be_valid
          expect(Marketplace::Product.new(@params.merge(attr => "a"*256))).not_to be_valid
        end
      end
    end

    describe "form options" do
      %w(fat_chops rubbish).each do |invalid_form|
        it "should be invalid when form is set to '#{invalid_form}'" do
          expect(Marketplace::Product.new(@params.merge(form: invalid_form))).not_to be_valid
        end
      end

      Marketplace::ProductForm::PERMITTED.each do |valid_form|
        it "should be valid when form is set to '#{valid_form}'" do
          expect(Marketplace::Product.new(@params.merge(form: valid_form))).to be_valid
        end
      end
    end

    describe "name uniqueness" do
      before :all do
        @product = @pharmacy.products.create(@params)
        @other_pharmacy = create_pharmacy(name: "Other pharmacy", email: "info@otherpharmacy.com")
      end

      describe "product active" do
        before :each do
          @new_params = @params.merge(active: true)
        end

        it "should be invalid if :name, :pack_size and :strength is not unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params)).to be_invalid
        end

        it "should be valid if :name is unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(name: "New_name"))).to be_valid
        end

        it "should be valid if :pack_size is unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(pack_size: "80"))).to be_valid
        end

        it "should be valid if :strength is unique for the given pharmacy" do
          expect(@pharmacy.products.build(@new_params.merge(strength: "2"))).to be_valid
        end

        it "should be valid if duplicate product belongs to a different pharmacy" do
          expect(Marketplace::Product.new(@new_params.merge(pharmacy: @other_pharmacy))).to be_valid
        end
      end

      describe "product inactive" do
        before :each do
          @new_params = @params.merge(active: false)
        end

        it "should be valid if :name and :pack_size are not unique for the pharmacy" do
          expect(@pharmacy.products.build(@new_params)).to be_valid
        end
      end
    end
  end

  describe "instance method" do
    before :all do
      @product = create_product({
        form: "cream"
      })
    end

    describe "product_form" do
      it "should return an instance of Marketplace::ProductForm" do
        expect(@product.product_form).to be_a Marketplace::ProductForm
      end

      it "should return nil if the #form is not set on the product" do
        @product.form = nil
        expect(@product.product_form).to be_nil
      end
    end

    describe "#display_strength" do
      it "should return a String" do
        expect(@product.display_strength).to be_a String
      end

      it "should return a blank string where :strength is not set" do
        @product.strength = nil
        expect(@product.display_strength).to be_blank
      end

      it "should return a string representing the strength with the appropriate unit" do
        @product.form = "cream"
        @product.strength = 2.5
        expect(@product.display_strength).to eq "2.5 %"
      end
    end

    describe "#display_pack_size" do
      it "should return a String" do
        expect(@product.display_pack_size).to be_a String
      end

      it "should return a blank string where :pack_size is not set" do
        @product.pack_size = nil
        expect(@product.display_pack_size).to be_blank
      end

      it "should return a string representing the pack_size with the appropriate unit" do
        @product.form = "cream"
        @product.pack_size = 200
        expect(@product.display_pack_size).to eq "200 g"
      end
    end
  end
end
