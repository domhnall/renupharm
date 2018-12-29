require 'rails_helper'

describe Marketplace::CreditCardsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy
    @credit_card = create_credit_card(pharmacy: @pharmacy)

    @superintendent = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "super@baggs.com"),
      superintendent: true
    ).user.becomes(Users::Agent)

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)

    @other_user = create_agent(
      pharmacy: create_pharmacy,
      user: create_user(email: "sam@jones.com"),
      superintendent: true
    ).user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: "adam@renupharm.ie")
  end

  describe "#new" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :new, params: {pharmacy_id: @pharmacy.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      describe "who is not superintendent of pharmacy" do
        before :each do
          sign_in @user
        end

        it "should redirect user to the sign in path" do
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response).to redirect_to root_path
        end

        it "should set a flash message to indicate that user has no access to create agents" do
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(flash[:error]).to eq I18n.t('errors.access_denied')
        end

        it "should return a successful response where user is an admin" do
          sign_in @admin_user
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response.status).to eq 200
        end

        describe "wrong :pharmacy_id specified on request" do
          it "should redirect user" do
            sign_in @other_user
            get :new, params: {pharmacy_id: @pharmacy.id}
            expect(response).to redirect_to root_path
          end
        end
      end

      describe "who is superintendent of pharmacy" do
        before :each do
          sign_in @superintendent
        end

        it "should return a successful response" do
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response.status).to eq 200
        end

        it "should render the :new template" do
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response.body).to render_template :new
        end
      end
    end
  end

  describe "#create" do
    before :all do
      @create_params = {
        pharmacy_id: @pharmacy.id,
        marketplace_credit_card: {
          email: "domhnallmurphy@hotmail.com"
        },
        "adyen-encrypted-data"=>"adyenjs_0_1_23$FytsEqgyTxJ2SGh/bPg0pugRiSb0HSspvtdsnmPnpzM5bEgH66YUlbqPp6wJRCRL2sGeKan9fHisdcVyIHEAfg1Oua2IU3yWu14GAJV4/prkwmy+X6SOR+FBOuhVq0Qf5rPu9ViSA6mId7q2DF7r9VRzB4N2tVNSLS1oN+F8AyeCsjDzBjZC7IAkNmHAr6BRlPiypQUrFceHRhJpqaXAC2mMyZHPB+0ffBKPzNC1WKN/Eh5Y2S/94+5UsXfEDLn0dYP4+kLRBfeNfgZ9J47dsqTxOi9Mf0NPJnE5TnmmsIuFZPMArVT0y1gKyx7MTv64ZwRuKvod2lrka2xdxUCBwg==$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"
      }
    end

    before :each do
      allow(PAYMENT_GATEWAY).to receive(:purchase).and_return(Adyen::PurchaseResponse.new("paymentResult.pspReference=7913990310819176&paymentResult.authCode=61824&paymentResult.resultCode=Authorised"))
    end

    describe "unauthenticated user" do
      it "should redirect user" do
        post :create, params: @create_params
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        post :create, params: @create_params
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated user" do
      describe "who is not superintendent of pharmacy" do
        before :each do
          sign_in @user
        end

        it "should redirect user to the root path" do
          post :create, params: @create_params
          expect(response).to redirect_to root_path
        end

        it "should set a flash message to indicate that user has no access to create agents" do
          post :create, params: @create_params
          expect(flash[:error]).to eq I18n.t('errors.access_denied')
        end

        it "should successfully create the agent where user is an admin" do
          orig_count = @pharmacy.credit_cards.reload.count
          sign_in @admin_user
          post :create, params: @create_params
          expect(@pharmacy.credit_cards.reload.count).to eq orig_count+1
        end
      end

      describe "who is superintendent of pharmacy" do
        before :each do
          sign_in @superintendent
        end

        it "should successfully create the credit card" do
          orig_count = @pharmacy.credit_cards.reload.count
          post :create, params: @create_params
          expect(@pharmacy.credit_cards.reload.count).to eq orig_count+1
        end

        it "should redirect the user to the pharmacy path" do
          post :create, params: @create_params
          expect(response).to redirect_to marketplace_pharmacy_path(@pharmacy)
        end

        it "should set a flash message to indicate that agent has been successfully created" do
          post :create, params: @create_params
          expect(flash[:success]).to eq I18n.t('marketplace.credit_card.flash.create_successful')
        end
      end
    end
  end
end
