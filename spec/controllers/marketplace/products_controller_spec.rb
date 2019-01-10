require 'rails_helper'

describe Marketplace::ProductsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Baggs Boutique", email: "info@baggs.com").tap do |pharmacy|
      @pharmacy_product = create_product(pharmacy: pharmacy, name: "Budweiser")
    end
    @generic_product = create_product(pharmacy: nil)

    @user = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "stuart@baggs.com")
    ).user.becomes(Users::Agent)

    @other_user = create_agent(
      pharmacy: create_pharmacy(name: "Jones' Pharms", email: "jon@jones.com"),
      user: create_user(email: "sam@jones.com")
    ).user.becomes(Users::Agent)

    @admin_user = create_admin_user(email: "adam@renupharm.ie")

    ::Marketplace::Product.reindex
  end

  describe "#index" do
    describe "unauthenticated user" do
      it "should redirect user" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        get :index
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful reponse" do
        get :index, params: { pharmacy_id: @pharmacy.id }
        expect(response).to have_http_status 200
      end

      it "should render the dashboard layout" do
        get :index, params: { pharmacy_id: @pharmacy.id }
        expect(response).to render_template 'layouts/dashboards'
      end

      it "should list products for the agents pharmacy" do
        get :index, params: { pharmacy_id: @pharmacy.id }
        expect(assigns(:products).map(&:id)).to include @pharmacy_product.id
      end

      it "should list generic products" do
        get :index, params: { pharmacy_id: @pharmacy.id }
        expect(assigns(:products).map(&:id)).to include @generic_product.id
      end

      it "should not list products from other pharmacies" do
        sign_in @other_user
        get :index, params: { pharmacy_id: @other_user.pharmacy.id }
        expect(assigns(:products).map(&:id)).not_to include @pharmacy_product.id
        expect(assigns(:products).map(&:id)).to include @generic_product.id
        get :index, params: { pharmacy_id: @pharmacy.id }
        expect(assigns(:products).map(&:id)).not_to include @pharmacy_product.id
      end

      describe "renupharm admin" do
        before :each do
          sign_in @admin_user
        end

        it "should return a successful reponse" do
          get :index
          expect(response).to have_http_status 200
        end

        it "should list all generic products" do
          get :index
          expect(assigns(:products).map(&:id)).to include @generic_product.id
        end
      end
    end
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show, params: {id: @pharmacy_product.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show, params: {id: @pharmacy_product.id}
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show, params: {id: @pharmacy_product.id}
        expect(response.body).to render_template :show #"marketplace/products/show"
      end
    end
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
        expect(response.body).to render_template :new #"marketplace/products/show"
      end

      describe "no :pharmacy_id specified on request" do
        it "should redirect user" do
          get :new
          expect(response).to redirect_to root_path
        end

        it "should return a successful response where user is an admin" do
          sign_in @admin_user
          get :new
          expect(response.status).to eq 200
        end
      end

      describe "wrong :pharmacy_id specified on request" do
        it "should redirect user" do
          sign_in @other_user
          get :new, params: {pharmacy_id: @pharmacy.id}
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe "#create" do
    before :all do
      @create_params = {
        pharmacy_id: @pharmacy.id,
        marketplace_product: {
          images: [],
          delete_images: "",
          name: "chubby checker",
          active_ingredient: "marzipan",
          form: "hard_capsules",
          strength: "5mg",
          manufacturer: "Mattel",
          pack_size: "40",
          active: "1"
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

      it "should create a new product in the database" do
        orig_count = @pharmacy.products.reload.count
        post :create, params: @create_params
        expect(@pharmacy.products.reload.count).to eq orig_count+1
      end

      it "should set a successful flash message" do
        post :create, params: @create_params
        expect(flash[:success]).to eq I18n.t('marketplace.product.flash.create_successful')
      end

      it "should redirect the user to the show page" do
        post :create, params: @create_params
        expect(response).to redirect_to marketplace_product_path(::Marketplace::Product.last)
      end

      it "should not create a product if pharmacy_id is not specified" do
        post :create, params: @create_params.merge(pharmacy_id: nil)
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eq I18n.t('errors.access_denied')
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
          orig_count = ::Marketplace::Product.count
          post :create, params: @create_params.merge(pharmacy_id: nil)
          expect(::Marketplace::Product.count).to eq orig_count+1
        end

        it "should redirect the admin to the show page" do
          post :create, params: @create_params.merge(pharmacy_id: nil)
          expect(response).to redirect_to marketplace_product_path(::Marketplace::Product.last)
        end
      end
    end
  end

  describe "#edit" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :edit, params: {id: @pharmacy_product.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :edit, params: {id: @pharmacy_product.id}
        expect(response.status).to eq 200
      end

      it "should render the :edit template" do
        get :edit, params: {id: @pharmacy_product.id}
        expect(response.body).to render_template :edit #"marketplace/products/show"
      end
    end
  end

  describe "#update" do
    before :all do
      @update_params = {
        id: @pharmacy_product.id,
        pharmacy_id: @pharmacy.id,
        marketplace_product: {
          id: "90",
          pharmacy_id: "80",
          images: [],
          delete_images: "",
          name: "chubby checker",
          active_ingredient: "marzipan",
          form: "hard_capsules",
          strength: "5mg",
          manufacturer: "Mattel",
          pack_size: "40",
          active: "1"
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
        expect(@pharmacy_product.reload.name).not_to eq "chubby checker"
        put :update, params: @update_params
        expect(@pharmacy_product.reload.name).to eq "chubby checker"
      end

      it "should set a successful flash message" do
        put :update, params: @update_params
        expect(flash[:success]).to eq I18n.t('marketplace.product.flash.update_successful')
      end

      it "should redirect the user to the show page" do
        put :update, params: @update_params
        expect(response).to redirect_to marketplace_product_path(@pharmacy_product)
      end

      it "should not update the product if pharmacy_id is not specified" do
        put :update, params: @update_params.merge(pharmacy_id: nil)
        expect(response).to redirect_to root_path
        expect(flash[:error]).to eq I18n.t('errors.access_denied')
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
          expect(@pharmacy_product.reload.name).not_to eq "chubby checker"
          put :update, params: @update_params.merge(pharmacy_id: nil)
          expect(@pharmacy_product.reload.name).to eq "chubby checker"
        end

        it "should redirect the admin to the show page" do
          put :update, params: @update_params.merge(pharmacy_id: nil)
          expect(response).to redirect_to marketplace_product_path(@pharmacy_product)
        end
      end
    end
  end
end
