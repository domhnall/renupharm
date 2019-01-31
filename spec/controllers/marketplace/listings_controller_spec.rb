require 'rails_helper'

describe Marketplace::ListingsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy
    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)
  end

  describe "#index" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :index
        expect(response.status).to eq 200
      end

      it "should render the :index template" do
        get :index
        expect(response.body).to render_template :index
      end
    end
  end

  describe "#show" do
    before :all do
      @listing = create_listing
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show, params: { id: @listing.id }
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show, params: { id: @listing.id }
        expect(response.status).to eq 200
      end

      it "should render the :index template" do
        get :show, params: { id: @listing.id }
        expect(response.body).to render_template :show
      end
    end
  end

  describe "#destroy" do
    before :each do
      @listing_for_destroy = create_listing(pharmacy: @pharmacy)
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        delete :destroy, params: {id: @listing_for_destroy.id, pharmacy_id: @pharmacy.id}
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        delete :destroy, params: {id: @listing_for_destroy.id, pharmacy_id: @pharmacy.id}
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated pharmacy user" do
      before :each do
        sign_in @user
      end

      it "should delete the listing from the database" do
        expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
        delete :destroy, params: {id: @listing_for_destroy.id, pharmacy_id: @pharmacy.id}
        expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 0
      end

      it "should set a successful flash message" do
        delete :destroy, params: {id: @listing_for_destroy.id, pharmacy_id: @pharmacy.id}
        expect(flash[:success]).to eq I18n.t('marketplace.listing.flash.destroy_successful')
      end

      it "should redirect the user to the listings page for the pharmacy" do
        delete :destroy, params: {id: @listing_for_destroy.id, pharmacy_id: @pharmacy.id}
        expect(response).to redirect_to marketplace_pharmacy_listings_path(@pharmacy)
      end

      it "should not delete the listing if it has completed line items" do
        create_order(listing: @listing_for_destroy, state: Marketplace::Order::State::COMPLETED)
        delete :destroy, params: {id: @listing_for_destroy.id, pharmacy_id: @pharmacy.id}
        expect(response.status).to eq 422
        expect(flash[:error]).to eq I18n.t('general.error')
      end

      describe "renupharm admin" do
        before :all do
          @admin_user = create_admin_user
        end

        before :each do
          sign_in @admin_user
        end

        it "should delete the listing from the database" do
          expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 1
          delete :destroy, params: {id: @listing_for_destroy.id}
          expect(Marketplace::Listing.where(id: @listing_for_destroy.id).count).to eq 0
        end

        it "should set a successful flash message" do
          delete :destroy, params: {id: @listing_for_destroy.id}
          expect(flash[:success]).to eq I18n.t('marketplace.listing.flash.destroy_successful')
        end

        it "should redirect the admin user to the overall listings page page" do
          delete :destroy, params: {id: @listing_for_destroy.id}
          expect(response).to redirect_to marketplace_root_path
        end
      end
    end
  end
end
