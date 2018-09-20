require 'rails_helper'

describe Admin::Sales::PharmaciesController do
  include Factories

  before :all do
    @existing = Sales::Pharmacy.create!({
      name: "Sandymount Pharmacy on the Green",
      address_1:  "1a Sandymount Green",
      address_2: "Dublin 4, Irishtown",
      address_3: "Dublin 4",
      telephone: "(01) 283 7188",
    })

    @create_params = {
      sales_pharmacy: {
        name: "DrugsRUs",
        proprietor: "R Kelly",
        address_1: "99 Bun Road",
        address_3: "Caketown",
        email: "rkelly@rnb.com"
      }
    }

    @update_params = @create_params.merge(id: @existing.id)
  end

  it_behaves_like "a basic admin controller with :index"
  it_behaves_like "a basic admin controller with :show"
  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :create", Sales::Pharmacy
  it_behaves_like "a basic admin controller with :update", Sales::Pharmacy
  it_behaves_like "a basic admin controller with :destroy", Sales::Pharmacy

  describe "an authenticated admin" do
    before :all do
      @admin = create_user(email: 'dom@renupharm.ie')
      @pharmacy = Sales::Pharmacy.create!({
        name: "Bloggs",
        address_1: "8a Greenan Road",
        address_3: "Caketown",
        email: "joe@bloggs.com"
      })
    end

    before :each do
      sign_in @admin
    end

    describe "#index" do
      render_views

      it "should display name for each Sales::Pharmacy" do
        get :index
        expect(response.body).to include @pharmacy.name
      end
    end
  end
end
