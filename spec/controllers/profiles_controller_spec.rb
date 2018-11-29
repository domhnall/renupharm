require 'rails_helper'

describe ProfilesController do
  include Factories::Marketplace

  before :all do
    @user = create_agent(
      pharmacy: create_pharmacy(name: "Bagg's Pharmacy", email: "billy@baggs.com"),
      email: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show
        expect(response.body).to render_template :show
      end
    end
  end

  describe "#edit" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :edit
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :edit
        expect(response.status).to eq 200
      end

      it "should render the :edit template" do
        get :edit
        expect(response.body).to render_template :edit
      end
    end
  end

  describe "#update" do
    before :all do
      @update_params = {
        id: @user.profile.id,
        profile: {
          first_name: 'Jerome'
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
      before :each do
        sign_in @user
      end

      it "should redirect the user to the :show view" do
        put :update, params: @update_params
        expect(response).to redirect_to profile_path
      end

      it "should set a flash message to indicate that update has been successful" do
        put :update, params: @update_params
        expect(flash[:success]).to eq I18n.t("general.flash.update_successful")
      end

      it "should update the profile of the logged in user" do
        expect(@user.profile.reload.first_name).not_to eq @update_params[:profile][:first_name]
        put :update, params: @update_params
        expect(@user.profile.reload.first_name).to eq @update_params[:profile][:first_name]
      end
    end
  end
end
