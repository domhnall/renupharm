#
# Requires a hash for @create_params to be defined
#

shared_examples "a basic admin controller with :create" do |clazz, options = {}|
  before :all do
    @user ||= create_user(email: 'creator@example.com')
    @admin_user = create_admin_user(email: 'creator@renupharm.ie')
    @clazz = clazz
    @create_params ||= {}
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

    describe "renupharm admin" do
      before :each do
        sign_in @admin_user
      end

      it "should create a new entity" do
        orig_count = @clazz.count
        post :create, params: @create_params
        expect(@clazz.count).to eq orig_count+1
      end

      it "should redirect the user to the show page" do
        post :create, params: @create_params
        expect(response).to redirect_to (@successful_create_redirect || self.send("admin_#{@clazz.to_s.gsub("::","_").downcase}_path", @clazz.last))
      end
    end
  end
end
