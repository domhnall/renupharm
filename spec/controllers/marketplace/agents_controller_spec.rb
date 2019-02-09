require 'rails_helper'

describe Marketplace::AgentsController do
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

    @agent_to_be_edited = create_agent(
      pharmacy: @pharmacy,
      user: create_user(email: "needschanging@baggs.com")
    )

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

  describe "#edit" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      describe "who is not superintendent of pharmacy" do
        before :each do
          sign_in @user
        end

        it "should redirect user to the sign in path" do
          get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
          expect(response).to redirect_to root_path
        end

        it "should set a flash message to indicate that user has no access to create agents" do
          get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
          expect(flash[:error]).to eq I18n.t('errors.access_denied')
        end

        it "should return a successful response where user is an admin" do
          sign_in @admin_user
          get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
          expect(response.status).to eq 200
        end

        describe "wrong :pharmacy_id specified on request" do
          it "should redirect user" do
            sign_in @other_user
            get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
            expect(response).to redirect_to root_path
          end
        end
      end

      describe "who is superintendent of pharmacy" do
        before :each do
          sign_in @superintendent
        end

        it "should return a successful response" do
          get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
          expect(response.status).to eq 200
        end

        it "should render the :new template" do
          get :edit, params: {id: @agent_to_be_edited.id, pharmacy_id: @pharmacy.id}
          expect(response.body).to render_template :edit
        end
      end
    end
  end

  describe "#create" do
    before :all do
      @create_params = {
        pharmacy_id: @pharmacy.id,
        marketplace_agent: {
          user_attributes: {
            email: "donkey@renupharm.ie",
            password: "foobar",
            password_confirmation: "foobar",
            profile_attributes: {
              first_name: "Donkey",
              surname: "Murphy",
              telephone: "0868140586",
              role: "pharmacy"
            },
            superintendent: "0"
          }
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
          orig_count = @pharmacy.agents.reload.count
          sign_in @admin_user
          post :create, params: @create_params
          expect(@pharmacy.agents.reload.count).to eq orig_count+1
        end
      end

      describe "who is superintendent of pharmacy" do
        before :each do
          sign_in @superintendent
        end

        it "should successfully create the agent" do
          orig_count = @pharmacy.agents.reload.count
          post :create, params: @create_params
          expect(@pharmacy.agents.reload.count).to eq orig_count+1
        end

        it "should redirect the user to the pharmacy path" do
          post :create, params: @create_params
          expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @pharmacy.id, section: 'agents')
        end

        it "should set a flash message to indicate that agent has been successfully created" do
          post :create, params: @create_params
          expect(flash[:success]).to eq I18n.t("general.flash.create_successful")
        end
      end
    end
  end

  describe "#update" do
    before :all do
      @agent = create_agent(pharmacy: @pharmacy)
      @update_params = {
        id: @agent.id,
        pharmacy_id: @pharmacy.id,
        marketplace_agent: {
          user_attributes: {
            id: @agent.user.id,
            profile_attributes: {
              id: @agent.profile.id,
              first_name: "Horse",
            },
          },
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

        it "should set a flash message to indicate that user has no access to create agents" do
          put :update, params: @update_params
          expect(flash[:error]).to eq I18n.t('errors.access_denied')
        end

        it "should successfully update the agent where user is an admin" do
          expect(@pharmacy.agents.reload.last.first_name).not_to eq "Horse"
          sign_in @admin_user
          put :update, params: @update_params
          expect(@pharmacy.agents.reload.last.first_name).to eq "Horse"
        end
      end

      describe "who is superintendent of pharmacy" do
        before :each do
          sign_in @superintendent
        end

        it "should successfully update the agent" do
          expect(@pharmacy.agents.reload.last.first_name).not_to eq "Horse"
          put :update, params: @update_params
          expect(@pharmacy.agents.reload.last.first_name).to eq "Horse"
        end

        it "should redirect the user to the pharmacy path" do
          put :update, params: @update_params
          expect(response).to redirect_to marketplace_pharmacy_profile_path(pharmacy_id: @pharmacy.id, section: 'agents')
        end

        it "should set a flash message to indicate that agent has been successfully updated" do
          put :update, params: @update_params
          expect(flash[:success]).to eq I18n.t("general.flash.update_successful")
        end
      end
    end
  end
end
