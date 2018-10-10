#
# Requires an @existing instance to be defined
#

shared_examples "a basic admin controller with :destroy" do |clazz|
  before :all do
    @user = create_user(email: 'destroyer@example.com')
    @admin_user = create_admin_user(email: 'destroyer@renupharm.ie')
    @clazz = clazz
  end

  describe "unauthenticated user" do
    it "should redirect user" do
      delete :destroy, params: { id: @existing.id }
      expect(response).to redirect_to new_user_session_path
    end

    it "should set an appropriate flash message" do
      delete :destroy, params: { id: @existing.id }
      expect(flash[:alert]).to eq I18n.t("devise.failure.unauthenticated")
    end
  end

  describe "authenticated user" do
    before :each do
      sign_in @user
    end

    it "should redirect user" do
      delete :destroy, params: { id: @existing.id }
      expect(response).to redirect_to root_path
    end

    it "should set an appropriate flash message" do
      delete :destroy, params: { id: @existing.id }
      expect(flash[:error]).to eq I18n.t("errors.access_denied")
    end

    describe "renupharm admin" do
      before :each do
        sign_in @admin_user
      end

      it "should reduce the record count accordingly" do
        orig_count = @clazz.count
        delete :destroy, params: { id: @existing.id }
        expect(@clazz.count).to eq orig_count-1
      end

      it "should delete the specified entity" do
        orig_json = @clazz.find(@existing.id).to_json
        expect(@clazz.where(id: @existing.id)).not_to be_empty
        delete :destroy, params: { id: @existing.id }
        expect(@clazz.where(id: @existing.id)).to be_empty
      end

      it "should redirect the user to the index page" do
        delete :destroy, params: { id: @existing.id }
        expect(response).to redirect_to self.send("admin_#{@clazz.table_name}_path")
      end
    end
  end
end
