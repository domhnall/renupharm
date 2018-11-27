require 'rails_helper'

describe Admin::Marketplace::AgentsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "McArdle's", email: "harry@mcardles.com")
    @user = create_agent(pharmacy: @pharmacy, user: create_user(email: "tester@test.com")).user
    @existing = create_agent(pharmacy: @pharmacy)

    @create_params = {
      pharmacy_id: @pharmacy.id,
      marketplace_agent: {
        user_attributes: {
          email: 'agent@example.com',
          password: 'foobar',
          password_confirmation: 'foobar',
          profile_attributes: {
            first_name: 'Agent',
            surname: 'Orange',
            role: Profile::Roles::PHARMACY
          }
        },
        pharmacy: @pharmacy
      }
    }

    @update_params = @create_params.merge(id: @existing.id)
    @additional_params = {pharmacy_id: @pharmacy.id}
    @successful_create_redirect = "/admin/marketplace/pharmacies/#{@pharmacy.id}"
    @successful_update_redirect = "/admin/marketplace/pharmacies/#{@pharmacy.id}"
  end

  it_behaves_like "a basic admin controller with :edit"
  it_behaves_like "a basic admin controller with :new"
  it_behaves_like "a basic admin controller with :create", Marketplace::Agent
  it_behaves_like "a basic admin controller with :update", Marketplace::Agent
end
