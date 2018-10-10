require 'rails_helper'

describe Admin::UsersController do
  include Factories

  before :all do
    @existing = create_user(email: "existing@user.com")

    @create_params = {
      user: {
        email: "dodge@podge.com",
        password: "PeggyPeggy",
        password_confirmation: "PeggyPeggy",
        profile_attributes: {
          first_name: "Peggy",
          surname: "Olsen",
          role: Profile::Roles::PHARMACY
        }
      }
    }
  end

  it_behaves_like "a basic admin controller with :index"
  it_behaves_like "a basic admin controller with :show"
  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :create", User
  it_behaves_like "a basic admin controller with :destroy", User

  describe "an authenticated admin" do
    before :all do
      @admin = create_admin_user(email: "dom@renupharm.ie")
      @user = create_user(email: "gary@digney.com")
    end

    before :each do
      sign_in @admin
    end

    describe "#index" do
      render_views

      it "should display the email for each User" do
        get :index
        expect(response.body).to include @user.email
      end
    end
  end
end
