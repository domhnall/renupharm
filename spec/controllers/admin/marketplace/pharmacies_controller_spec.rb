require 'rails_helper'

describe Admin::Marketplace::PharmaciesController do
  include Factories::Marketplace

  before :all do
    @existing = create_pharmacy(name: "McArdle's", email: "harry@mcardles.com")

    @create_params = {
      marketplace_pharmacy: {
        name: "DrugsRUs",
        description: "We are a one-stop-shop for all your phamaceutical needs.",
        address_1: "99 Bun Road",
        address_3: "Caketown",
        email: "rkelly@rnb.com",
        telephone: "012345678",
        fax: "09876543"
      }
    }

    @update_params = @create_params.merge(id: @existing.id)
  end

  it_behaves_like "a basic admin controller with :index"
  it_behaves_like "a basic admin controller with :show"
  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :create", Marketplace::Pharmacy
  it_behaves_like "a basic admin controller with :update", Marketplace::Pharmacy

end
