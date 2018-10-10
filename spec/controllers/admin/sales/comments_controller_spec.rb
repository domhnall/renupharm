require 'rails_helper'

describe Admin::Sales::CommentsController do
  include Factories

  before :all do
    @user  = create_user(email: 'joe@schmoe.com')
    @admin = create_admin_user(email: 'admin@renupharm.ie')

    @commentable = Sales::Pharmacy.create!({
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4, Irishtown",
      address_3: "Dublin 4",
      telephone: "(01) 283 7188",
    })

    @existing = Comment.create!({
      commentable: @commentable,
      user: @admin,
      body: "This is a short note"
    })

    @create_params = {
      pharmacy_id: @commentable.id,
      comment: {
        body: "This is a new comment"
      }
    }

    @update_params = @create_params.merge(id: @existing.id)
  end

  describe "#create" do
    describe "non-authenticated user" do
      it "should redirect user" do
        post :create, params: @create_params
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        post :create, params: @create_params
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated non-admin user" do
      before :each do
        sign_in @user
      end

      it "should redirect user" do
        post :create, params: @create_params
        expect(response).to redirect_to root_path
      end

      it "should set an appropriate flash message" do
        post :create, params: @create_params
        expect(flash[:error]).to eq I18n.t("errors.access_denied")
      end
    end

    describe "authenticated admin user" do
      before :each do
        sign_in @admin
      end

      it "should create a new entity" do
        orig_count = Comment.count
        post :create, params: @create_params
        expect(Comment.count).to eq orig_count+1
      end

      it "should redirect the user to the show page for the commentable entity" do
        post :create, params: @create_params
        expect(response).to redirect_to admin_sales_pharmacy_path(@commentable)
      end
    end
  end

  describe "#update" do
    describe "non-authenticated user" do
      it "should redirect user" do
        put :update, params: @update_params
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        put :update, params: @update_params
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated non-admin user" do
      before :each do
        sign_in @user
      end

      it "should redirect user" do
        put :update, params: @update_params
        expect(response).to redirect_to root_path
      end

      it "should set an appropriate flash message" do
        put :update, params: @update_params
        expect(flash[:error]).to eq I18n.t("errors.access_denied")
      end
    end

    describe "authenticated admin user" do
      before :each do
        sign_in @admin
      end

      it "should not create a new entity" do
        orig_count = Comment.count
        put :update, params: @update_params
        expect(Comment.count).to eq orig_count
      end

      it "should update the existing entity" do
        orig_comment = @existing.reload.body
        put :update, params: @update_params
        expect(@existing.reload.body).not_to eq orig_comment
      end

      it "should redirect the user to the show page for the commentable entity" do
        put :update, params: @update_params
        expect(response).to redirect_to admin_sales_pharmacy_path(@commentable)
      end
    end
  end

  describe "#destroy" do
    describe "non-authenticated user" do
      it "should redirect user" do
        delete :destroy, params: { pharmacy_id: @existing.commentable_id, id: @existing.id }
        expect(response).to redirect_to new_user_session_path
      end

      it "should set an appropriate flash message" do
        delete :destroy, params: { pharmacy_id: @existing.commentable_id, id: @existing.id }
        expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
      end
    end

    describe "authenticated non-admin user" do
      before :each do
        sign_in @user
      end

      it "should redirect user" do
        delete :destroy, params: { pharmacy_id: @existing.commentable_id, id: @existing.id }
        expect(response).to redirect_to root_path
      end

      it "should set an appropriate flash message" do
        delete :destroy, params: { pharmacy_id: @existing.commentable_id, id: @existing.id }
        expect(flash[:error]).to eq I18n.t("errors.access_denied")
      end
    end

    describe "authenticated admin user" do
      before :each do
        sign_in @admin
      end

      it "should delete the comment" do
        orig_count = Comment.count
        delete :destroy, params: { pharmacy_id: @existing.commentable_id, id: @existing.id }
        expect(Comment.count).to eq orig_count-1
      end

      it "should redirect the user to the show page for the commentable entity" do
        delete :destroy, params: { pharmacy_id: @existing.commentable_id, id: @existing.id }
        expect(response).to redirect_to admin_sales_pharmacy_path(@commentable)
      end
    end
  end
end
