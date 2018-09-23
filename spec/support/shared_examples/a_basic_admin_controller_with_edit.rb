#
# Requires an @existing resource
#

shared_examples "a basic admin controller with :edit" do |clazz|
  before :all do
    @user = create_user(email: 'editor@example.com')
    @admin_user = create_user(email: 'editor@renupharm.ie')
    @clazz = clazz
  end

  describe "unauthenticated user" do
    it "should redirect user" do
      get :edit, params: { id: @existing.id }
      expect(response).to redirect_to new_user_session_path
    end

    it "should set an appropriate flash message" do
      get :edit, params: { id: @existing.id }
      expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
    end
  end

  describe "authenticated user" do
    before :each do
      sign_in @user
    end

    it "should redirect user" do
      get :edit, params: { id: @existing.id }
      expect(response).to redirect_to root_path
    end

    it "should set an appropriate flash message" do
      get :edit, params: { id: @existing.id }
      expect(flash[:error]).to eq I18n.t("errors.access_denied")
    end

    describe "renupharm admin" do
      before :each do
        sign_in @admin_user
      end

      it "should return a successful reponse" do
        get :edit, params: { id: @existing.id }
        expect(response).to have_http_status 200
      end

      it "should render the dashboard layout" do
        get :edit, params: { id: @existing.id }
        expect(response).to render_template 'layouts/dashboards'
      end
    end
  end
end