require 'rails_helper'

describe UsersHelper do
  include Factories::Base

  class TestView
    include UsersHelper
  end

  describe "instance method" do
    describe "#current_user" do
      before :all do
        @pharmacy_user = create_user({
          email: 'agent@pharmacy.com',
          role: Profile::Roles::PHARMACY
        })
        @admin_user = create_user({
          email: 'admin@renupharm.ie',
          role: Profile::Roles::ADMIN
        })
        @courier_user = create_user({
          email: 'courier@dpd.ie',
          role: Profile::Roles::COURIER
        })
      end

      before :each do
        @view_context = TestView.new
      end

      it "should return nil where the devise_current_user is nil" do
        allow(@view_context).to receive(:devise_current_user).and_return(nil)
        expect(@view_context.current_user).to be_nil
      end

      it "should return an instance of Users::Agent where devise_current_user is a pharmacy agent" do
        allow(@view_context).to receive(:devise_current_user).and_return(@pharmacy_user)
        expect(@view_context.current_user).to be_a Users::Agent
      end

      it "should return an instance of Users::Admin where devise_current_user is an admin" do
        allow(@view_context).to receive(:devise_current_user).and_return(@admin_user)
        expect(@view_context.current_user).to be_a Users::Admin
      end

      it "should return an instance of Users::Courier where devise_current_user is a courier" do
        allow(@view_context).to receive(:devise_current_user).and_return(@courier_user)
        expect(@view_context.current_user).to be_a Users::Courier
      end
    end
  end
end
