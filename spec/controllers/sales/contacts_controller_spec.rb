require 'rails_helper'

describe Sales::ContactsController do
  before :all do
    @sales_contact_params = {
      sales_contact: {
        first_name: "Domhnall",
        surname: "Murphy",
        email: "domhnallmurphy@hotmail.com"
      }
    }
  end

  describe "#create" do
    describe "when successful" do
      it "should create a new Sales::Contact record" do
        orig_count = Sales::Contact.count
        post :create, params: @sales_contact_params
        expect(Sales::Contact.count).to eq orig_count+1
      end

      it "should redirect the user back to the root page" do
        post :create, params: @sales_contact_params
        expect(response).to redirect_to root_path
      end

      it "should set an appropriate flash message" do
        post :create, params: @sales_contact_params
        expect(flash[:success]).to eq I18n.t("pages.index.register_interest.success")
      end
    end

    describe "when one of the required fields is absent" do
      before :each do
        @revised_contact_params = {
          sales_contact: {
            first_name: nil,
            surname: "Murphy",
            email: "domhnallmurphy@hotmail.com"
          }
        }
      end

      it "should not create a new Sales::Contact record" do
        orig_count = Sales::Contact.count
        post :create, params: @revised_contact_params
        expect(Sales::Contact.count).to eq orig_count
      end

      it "should redirect the user back to the root page" do
        post :create, params: @revised_contact_params
        expect(response).to redirect_to root_path
      end

      it "should set an appropriate flash message" do
        post :create, params: @revised_contact_params
        expect(flash[:warning]).to eq I18n.t("pages.index.register_interest.error")
      end
    end

    describe "when the contact already exists" do
      before :all do
        @existing_contact = Sales::Contact.create!(@sales_contact_params[:sales_contact])
      end

      it "should not create a new Sales::Contact record" do
        orig_count = Sales::Contact.count
        post :create, params: @sales_contact_params
        expect(Sales::Contact.count).to eq orig_count
      end

      it "should redirect the user back to the root page" do
        post :create, params: @sales_contact_params
        expect(response).to redirect_to root_path
      end

      it "should set an appropriate flash message" do
        post :create, params: @sales_contact_params
        expect(flash[:info]).to eq I18n.t("pages.index.register_interest.already_exists")
      end
    end
  end
end
