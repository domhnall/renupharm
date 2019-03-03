require 'rails_helper'

describe WebPushSubscriptionsController do
  include Factories::Marketplace

  before :all do
    @user = create_agent.user.becomes(Users::Agent)
    @profile = @user.profile
    @other_profile = create_user.profile
  end

  describe "#update" do
    before :each do
      @create_params = {
        web_push_subscription: {
          subscription: {
            "keys"=>{
              "auth"=>"ZRdZ9iDbURjZjnA3pCSEvQ",
              "p256dh"=>"BHiz1CA2i3aO99VBkH0FclPivQg3rl0lHEygJUypodsPg2YxcwBSNNxSK4zym33lcz7olOcmE1phjPnGt4IE06U"
            },
            "endpoint"=>"https://updates.push.services.mozilla.com/wpush/v2/gAAAAABcewZQcQelD95rMg77YGrLTZAbDZ6e0p7by9XfTt_EbN42WUSlmtcrJI2-0c9GCOeVMj2k4S2fLXN4gkHqi8OyCoEI4Q02iRXxSOKaITM4P1gC1EVysvGELdV-_G6Ab66GSh5kG6qboTIQF7fm75fYLLP2CLHlZDsO6ahhc2hPQHVvEec"
          }
        }
      }
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        post :create, params: @create_params
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        post :create, params: @create_params
        expect(response.status).to eq 200
      end

      it "should create a new web_push_subscription for the user" do
        orig_count = @profile.web_push_subscriptions.count
        post :create, params: @create_params
        expect(@profile.web_push_subscriptions.count).to eq orig_count+1
      end

      describe "where :profile_id not matching current user is supplied" do
        it "should still create the web_push_subscription for the current user" do
          orig_count = @profile.web_push_subscriptions.count
          post :create, params: @create_params.deep_merge(web_push_subscription: { profile_id: @other_profile.id })
          expect(@profile.web_push_subscriptions.count).to eq orig_count+1
        end
      end

      describe "where no subscription is supplied" do
        it "should return a 422" do
          post :create, params: @create_params.deep_merge(web_push_subscription: { subscription: nil })
          expect(response.status).to eq 422
        end

        it "should return a JSON response including the error" do
          post :create, params: @create_params.deep_merge(web_push_subscription: { subscription: nil })
          json = JSON.parse(response.body)
          expect(json.keys).to include "errors"
          expect(json["errors"].size).to eq 1
          expect(json["errors"].first).to include I18n.t("errors.messages.blank")
        end

        it "should not create a new web_push_subscription" do
          orig_count = @profile.web_push_subscriptions.count
          post :create, params: @create_params.deep_merge(web_push_subscription: { subscription: nil })
          expect(@profile.web_push_subscriptions.count).to eq orig_count
        end
      end
    end
  end
end
