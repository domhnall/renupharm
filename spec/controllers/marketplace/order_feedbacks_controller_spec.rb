require 'rails_helper'

describe Marketplace::OrderFeedbacksController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Baggs Boutique", email: "info@baggs.com")

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)

    @other_user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "frank@baggs.com")
    ).user.becomes(Users::Agent)

    @other_pharmacy_user = create_agent(
      pharmacy: create_pharmacy(name: "Jones' Pharms", email: "jon@jones.com"),
      user: create_user(email: "sam@jones.com")
    ).user.becomes(Users::Agent)

    @order = create_order(agent: @user.agent, state: Marketplace::Order::State::COMPLETED)
  end

  describe "#create" do
    before :all do
      @create_params = {
        order_id: @order.id,
        marketplace_order_feedback: {
          rating: 2,
          message: "This is some brief feedback"
        }
      }
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        post :create, params: @create_params
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user from another pharmacy" do
      before :each do
        sign_in @other_pharmacy_user
      end

      it "should return a 404 response" do
        post :create, params: @create_params
        expect(response.status).to eq 404
      end

      it "should set an appropriate flash message" do
        post :create, params: @create_params
        expect(flash[:error]).to include I18n.t('errors.record_not_found')
      end
    end

    describe "authenticated user from same pharmacy" do
      before :each do
        sign_in @other_user
      end

      it "should return a successful response" do
        post :create, params: @create_params
        expect(response.status).to redirect_to marketplace_order_path(@order)
      end

      it "should set an appropriate flash message" do
        post :create, params: @create_params
        expect(flash[:success]).to include I18n.t("marketplace.order_feedback.flash.create_successful")
      end

      it "should create the feedback on the order" do
        expect(@order.reload.feedback).to be_nil
        post :create, params: @create_params
        expect(@order.reload.feedback).not_to be_nil
        expect(@order.feedback.rating).to eq 2
      end
    end
  end

  describe "#update" do
    before :all do
      @order_feedback = @order.create_feedback({
        user: @other_user,
        rating: 2,
        message: "Original message before updates"
      })

      @update_params = {
        order_id: @order.id,
        marketplace_order_feedback: {
          rating: 5,
          message: "This is my updated message with a 5-star rating"
        }
      }
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        patch :update, params: @update_params
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @other_pharmacy_user
      end

      it "should return a 404 response" do
        get :update, params: @update_params
        expect(response.status).to eq 404
      end

      it "should set an appropriate flash message" do
        get :update, params: @update_params
        expect(flash[:error]).to include I18n.t('errors.record_not_found')
      end
    end

    describe "original feedback author" do
      before :each do
        sign_in @other_user
      end

      it "should return a successful response" do
        patch :update, params: @update_params
        expect(response.status).to redirect_to marketplace_order_path(@order)
      end

      it "should set an appropriate flash message" do
        patch :update, params: @update_params
        expect(flash[:success]).to include I18n.t("marketplace.order_feedback.flash.update_successful")
      end

      it "should update the feedback on the order" do
        expect(@order.feedback.reload.rating).to eq 2
        patch :update, params: @update_params
        expect(@order.feedback.reload.rating).to eq 5
      end
    end
  end
end
