require 'rails_helper'

describe Marketplace::CreditCardsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy

    @superintendent = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "super@baggs.com"),
      superintendent: true
    ).user.becomes(Users::Agent)

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: "adam@renupharm.ie")
  end

  describe "#update" do
    before :all do
      @default_credit_card = create_credit_card(pharmacy: @pharmacy, default: true)
      @other_credit_card = create_credit_card(pharmacy: @pharmacy, default: false)
      @update_params = {
        id: @other_credit_card.id,
        pharmacy_id: @pharmacy.id,
        marketplace_credit_card: {
          default: true
        }
      }
    end

    describe "unauthenticated user" do
      it "should redirect user" do
        put :update, params: @update_params
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        put :update, params: @update_params
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated user" do
      describe "who is not superintendent of pharmacy" do
        before :each do
          sign_in @user
        end

        it "should redirect user to the root path" do
          put :update, params: @update_params
          expect(response).to redirect_to root_path
        end

        it "should set a flash message to indicate that user has no access to update existing cards" do
          put :update, params: @update_params
          expect(flash[:error]).to eq I18n.t('errors.access_denied')
        end

        it "should successfully update the credit card where user is an admin" do
          expect(@other_credit_card.reload.default).to be_falsey
          sign_in @admin_user
          put :update, params: @update_params
          expect(@other_credit_card.reload.default).to be_truthy
        end
      end

      describe "who is superintendent of pharmacy" do
        before :each do
          sign_in @superintendent
        end

        it "should redirect the user to the pharmacy profile credit cards path" do
          put :update, params: @update_params
          expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @pharmacy.id, section: 'credit_cards')
        end

        it "should set a flash message to indicate that the default credit card has been successfully set" do
          put :update, params: @update_params
          expect(flash[:success]).to eq I18n.t('marketplace.credit_card.flash.update_successful')
        end

        it "should successfully update the credit card" do
          expect(@other_credit_card.reload.default).to be_falsey
          put :update, params: @update_params
          expect(@other_credit_card.reload.default).to be_truthy
        end

        it "should update other credit_cards to be non-default" do
          expect(@default_credit_card.reload.default).to be_truthy
          expect(@other_credit_card.reload.default).to be_falsey
          put :update, params: @update_params
          expect(@default_credit_card.reload.default).to be_falsey
          expect(@other_credit_card.reload.default).to be_truthy
        end
      end
    end
  end
end
