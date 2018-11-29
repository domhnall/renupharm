require 'rails_helper'

describe Marketplace::PharmaciesController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Baggs Boutique", email: "info@baggs.com")
    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)
    @other_user = create_agent(
      pharmacy: create_pharmacy(name: "Stewart's", email: "stu@stewarts.com"),
      user: create_user(email: "dave@other.com")
    ).user.becomes(Users::Agent)
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show, params: {id: @pharmacy.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show, params: {id: @pharmacy.id}
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show, params: {id: @pharmacy.id}
        expect(response.body).to render_template "marketplace/shared/pharmacies/show"
      end
    end
  end

  describe "#edit" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :edit, params: {id: @pharmacy.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      describe "not an agent of the pharmacy" do
        before :each do
          sign_in @other_user
        end

        it "should redirect user to the root path" do
          get :edit, params: {id: @pharmacy.id}
          expect(response).to redirect_to root_path
        end

        it "should set an appropriate flash message" do
          get :edit, params: {id: @pharmacy.id}
          expect(flash[:error]).to eq I18n.t("errors.access_denied")
        end
      end

      describe "an agent of the pharmacy" do
        before :each do
          sign_in @user
        end

        it "should return a successful response" do
          get :edit, params: {id: @pharmacy.id}
          expect(response.status).to eq 200
        end

        it "should render the :edit template" do
          get :edit, params: {id: @pharmacy.id}
          expect(response.body).to render_template "marketplace/shared/pharmacies/edit"
        end
      end
    end
  end

  describe "#update" do
    before :all do
      @update_params = {
        id: @pharmacy.id,
        marketplace_pharmacy: {
          id: @pharmacy.id,
          name: "DrugsRYous",
          description: "We are a one-stop-shop for all your phamaceutical needs.",
          address_1: "99 Bun Road",
          address_3: "Caketown",
          email: "rkelly@rnb.com",
          telephone: "012345678",
          fax: "09876543"
        }
      }
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        put :update, params: @update_params
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      describe "not an agent of the pharmacy" do
        before :each do
          sign_in @other_user
        end

        it "should redirect user to the root path" do
          put :update, params: @update_params
          expect(response).to redirect_to root_path
        end

        it "should set an appropriate flash message" do
          put :update, params: @update_params
          expect(flash[:error]).to eq I18n.t("errors.access_denied")
        end
      end

      describe "an agent of the pharmacy" do
        before :each do
          sign_in @user
        end

        it "should redirect the user to the :show view" do
          put :update, params: @update_params
          expect(response).to redirect_to marketplace_pharmacy_path(@pharmacy)
        end

        it "should set a flash message to indicate that update has been successful" do
          put :update, params: @update_params
          expect(flash[:success]).to eq I18n.t("general.flash.update_successful")
        end

        it "should update the pharmacy record" do
          expect(@pharmacy.reload.name).not_to eq "DrugsRYous"
          put :update, params: @update_params
          expect(@pharmacy.reload.name).to eq "DrugsRYous"
        end

        it "should not be able to update the active flag for the pharmacy" do
          orig_name = @pharmacy.reload.name
          expect(@pharmacy).to be_active
          @update_params[:marketplace_pharmacy][:active] = false
          put :update, params: @update_params
          expect(@pharmacy.reload.name).not_to eq orig_name
          expect(@pharmacy).to be_active
        end

        describe "with an error in the parameters" do
          before :all do
            @update_params[:marketplace_pharmacy][:name] = "A" # Invalid as too short
          end

          it "should fail to update the pharmacy record" do
            orig_name = @pharmacy.reload.name
            put :update, params: @update_params
            expect(@pharmacy.reload.name).to eq orig_name
          end

          it "should render the :edit template" do
            get :update, params: @update_params
            expect(response.body).to render_template "marketplace/shared/pharmacies/edit"
          end

          it "should set a flash message to indicate that update has been unsuccessful" do
            put :update, params: @update_params
            expect(flash[:error]).to eq I18n.t("general.flash.error")
          end
        end
      end
    end
  end
end
