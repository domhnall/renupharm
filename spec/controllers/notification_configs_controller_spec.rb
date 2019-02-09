require 'rails_helper'

describe NotificationConfigsController do
  include Factories::Marketplace

  before :all do
    @user = create_agent.user.becomes(Users::Agent)
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

  describe "#show" do
    before :all do
      @update_params = {
        notification_config: {
          purchase_emails: false,
          purchase_texts: false,
          purchase_site_notifications: false,
          sale_emails: true,
          sale_texts: true,
          sale_site_notifications: true
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

      it "should update the config accordingly" do
        expect(@user.reload.purchase_emails?).to be_truthy
        put :update, params: @update_params
        expect(@user.reload.purchase_emails?).to be_falsey
      end

      it "should redirect the user to the :show view" do
        put :update, params: @update_params
        expect(response).to redirect_to notification_config_path
      end

      it "should set a flash message to indicate that update has been successful" do
        put :update, params: @update_params
        expect(flash[:success]).to eq I18n.t("notification_config.flash.update_successful")
      end
    end
  end
end
