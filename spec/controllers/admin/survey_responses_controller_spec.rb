require 'rails_helper'

describe Admin::SurveyResponsesController do
  include Factories

  it_behaves_like "a basic admin controller"

  describe "an authenticated admin" do
    before :all do
      @admin = create_user(email: 'dom@renupharm.ie')
      @contact = Sales::Contact.create!({
        first_name: "Gary",
        surname: "Digney",
        email: "gary@digney.com"
      })
      @survey = SurveyResponse.create!({
        sales_contact_id: @contact.id,
        question_1: true,
        question_2: true,
        question_3: true,
        question_4: true,
        question_5: "200_500",
        additional_notes: "I would not buy short dated medications"
      })
    end

    before :each do
      sign_in @admin
    end

    describe "#index" do
      render_views

      it "should display full name for the respondant" do
        get :index
        expect(response.body).to include @contact.full_name
      end
    end
  end
end
