require 'rails_helper'

describe Marketplace::BankAccountsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)

    @other_user = create_agent(
      pharmacy: create_pharmacy,
      user: create_user(email: "sam@jones.com")
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
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :new, params: {pharmacy_id: @pharmacy.id}
        expect(response.status).to eq 200
      end

      it "should render the :new template" do
        get :new, params: {pharmacy_id: @pharmacy.id}
        expect(response.body).to render_template :new
      end

      describe "wrong :pharmacy_id specified on request" do
        it "should redirect user" do
          sign_in @other_user
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response).to redirect_to root_path
        end

        it "should return a successful response where user is an admin" do
          sign_in @admin_user
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response.status).to eq 200
        end
      end
    end
  end

  describe "#create" do
    before :all do
      @create_params = {
        pharmacy_id: @pharmacy.id,
        marketplace_bank_account: {
          bank_name: "First Trust",
          bic: "BOFIIE2D",
          iban: "IE64BOFI90583812345678"
        }
      }
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

    describe "authenticated pharmacy user" do
      before :each do
        sign_in @user
      end

      it "should create a new BankAccount in the database" do
        orig_count = ::Marketplace::BankAccount.count
        post :create, params: @create_params
        expect(::Marketplace::BankAccount.count).to eq orig_count+1
      end

      it "should set a successful flash message" do
        post :create, params: @create_params
        expect(flash[:success]).to eq I18n.t('marketplace.bank_account.flash.update_successful')
      end

      it "should redirect the admin to the pharmacy profile page" do
        post :create, params: @create_params
        expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @pharmacy.id, section: 'bank_account')
      end

      it "should not create a product if :pharmacy_id does not correspond to the user's pharmacy" do
        post :create, params: @create_params.merge(pharmacy_id: @other_user.pharmacy.id)
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eq I18n.t('errors.access_denied')
      end

      describe "renupharm admin" do
        before :each do
          sign_in @admin_user
        end

        it "should create a new product in the database" do
          orig_count = ::Marketplace::BankAccount.count
          post :create, params: @create_params.merge(pharmacy_id: @other_user.pharmacy.id)
          expect(::Marketplace::BankAccount.count).to eq orig_count+1
        end

        it "should redirect the admin to the pharmacy profile page" do
          post :create, params: @create_params.merge(pharmacy_id: @other_user.pharmacy.id)
          expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @other_user.pharmacy.id, section: 'bank_account')
        end
      end
    end
  end

  describe "#edit" do
    before :all do
      @bank_account = @pharmacy.create_bank_account(
        bank_name: "Bank of Ireland",
        bic: "12345678",
        iban: "IE50 9080 9080"
      )
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :edit, params: {pharmacy_id: @pharmacy.id, id: @bank_account.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :edit, params: {pharmacy_id: @pharmacy.id, id: @bank_account.id}
        expect(response.status).to eq 200
      end

      it "should render the :edit template" do
        get :edit, params: {pharmacy_id: @pharmacy.id, id: @bank_account.id}
        expect(response.body).to render_template :edit
      end
    end
  end

  describe "#update" do
    before :all do
      @pharmacy.bank_account.destroy
      @bank_account = @pharmacy.create_bank_account(
        bank_name: "Bank of Ireland",
        bic: "12345678",
        iban: "IE50 9080 9080"
      )
      @update_params = {
        id: @bank_account.id,
        pharmacy_id: @pharmacy.id,
        marketplace_bank_account: {
          bank_name: "Churchill"
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

    describe "authenticated pharmacy user" do
      before :each do
        sign_in @user
      end

      it "should update the product in the database" do
        expect(@bank_account.reload.bank_name).not_to eq "Churchill"
        put :update, params: @update_params
        expect(@bank_account.reload.bank_name).to eq "Churchill"
      end

      it "should set a successful flash message" do
        put :update, params: @update_params
        expect(flash[:success]).to eq I18n.t('marketplace.bank_account.flash.update_successful')
      end

      it "should redirect the user to the pharmacy page" do
        put :update, params: @update_params
        expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @pharmacy.id, section: 'bank_account')
      end

      it "should not update the product if :pharmacy_id does not correspond to the user's pharmacy" do
        put :update, params: @update_params.merge(pharmacy_id: @other_user.pharmacy.id)
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eq I18n.t('errors.access_denied')
      end

      describe "renupharm admin" do
        before :each do
          sign_in @admin_user
        end

        it "should update the product in the database" do
          expect(@bank_account.reload.bank_name).not_to eq "Churchill"
          put :update, params: @update_params.merge(pharmacy_id: @pharmacy.id)
          expect(@bank_account.reload.bank_name).to eq "Churchill"
        end

        it "should redirect the admin to the pharmacy profile page" do
          put :update, params: @update_params.merge(pharmacy_id: @pharmacy.id)
          expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @pharmacy.id, section: 'bank_account')
        end
      end
    end
  end
end
