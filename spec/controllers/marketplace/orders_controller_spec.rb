require 'rails_helper'

describe Marketplace::OrdersController do
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
    @in_progress_order = create_order(agent: @user.agent, state: Marketplace::Order::State::IN_PROGRESS)
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show, params: {id: @order.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user from another pharmacy" do
      before :each do
        sign_in @other_pharmacy_user
      end

      it "should return a 404 response" do
        get :show, params: {id: @order.id}
        expect(response.status).to eq 404
      end

      it "should set an appropriate flash message" do
        get :show, params: {id: @order.id}
        expect(flash[:error]).to include I18n.t('errors.record_not_found')
      end
    end

    describe "authenticated user from same pharmacy" do
      before :each do
        sign_in @other_user
      end

      it "should return a successful response" do
        get :show, params: {id: @order.id}
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show, params: {id: @order.id}
        expect(response.body).to render_template :show
      end

      describe "accessing an in-progress order" do
        it "should return a 404 response" do
          get :show, params: {id: @in_progress_order.id}
          expect(response.status).to eq 404
        end
      end
    end
  end

  describe "#receipt" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :receipt, params: {id: @order.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user from another pharmacy" do
      before :each do
        sign_in @other_pharmacy_user
      end

      it "should return a 404 response" do
        get :receipt, params: {id: @order.id}
        expect(response.status).to eq 404
      end

      it "should set an appropriate flash message" do
        get :receipt, params: {id: @order.id}
        expect(flash[:error]).to include I18n.t('errors.record_not_found')
      end
    end

    describe "authenticated user from same pharmacy" do
      before :each do
        sign_in @other_user
      end

      it "should return a successful response" do
        get :receipt, params: {id: @order.id}
        expect(response.status).to eq 200
      end

      it "should render the :receipt template" do
        get :receipt, params: {id: @order.id}
        expect(response.body).to render_template :receipt
      end

      describe "accessing an in-progress order" do
        it "should return a 404 response" do
          get :receipt, params: {id: @in_progress_order.id}
          expect(response.status).to eq 404
        end
      end
    end
  end
end
