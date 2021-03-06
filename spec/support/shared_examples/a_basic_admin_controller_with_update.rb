#
# Requires a hash for @update_params to be defined
#

shared_examples "a basic admin controller with :update" do |clazz|
  include Factories::Marketplace

  before :all do
    @user ||= create_agent(
      pharmacy: create_pharmacy(name: "Updater's", email: "ursula@updaters.com"),
      user: create_user(email: 'updater@example.com')
    ).user.becomes(Users::Agent)
    @admin_user ||= create_admin_user(email: 'updater@renupharm.ie')
    @clazz = clazz
    @update_params ||= {}
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

    describe "renupharm admin" do
      before :each do
        sign_in @admin_user
      end

      it "should not create a new entity" do
        orig_count = @clazz.count
        put :update, params: @update_params
        expect(@clazz.count).to eq orig_count
      end

      it "should update the existing entity" do
        orig_json = @clazz.find(@update_params.fetch(:id)).to_json
        put :update, params: @update_params
        expect(@clazz.find(@update_params.fetch(:id)).to_json).not_to eq orig_json
      end

      it "should redirect the user to the show page" do
        put :update, params: @update_params
        expect(response).to redirect_to (@successful_update_redirect || self.send("admin_#{@clazz.to_s.gsub("::","_").downcase}_path", @clazz.find(@update_params.fetch(:id))))
      end
    end
  end
end
