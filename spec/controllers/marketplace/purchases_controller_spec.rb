require 'rails_helper'

describe Marketplace::PurchasesController do
  include Factories::Marketplace

  before :all do
    @payment = create_payment.tap do |payment|
      @order = payment.order
      @buying_pharmacy = @order.buying_pharmacy
      @selling_pharmacy = @order.selling_pharmacy
    end

    @agent = create_agent({
      pharmacy: @buying_pharmacy,
      user: create_user(email: 'non@collision.com')
    })

    @other_agent = create_agent({
      pharmacy: create_pharmacy(name: 'Bond', email: 'james@bond.com'),
      user: create_user(email: 'moneypenny@bond.com')
    })
  end

  describe "#index" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :index, params: { pharmacy_id: @buying_pharmacy.id }
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      render_views

      before :each do
        sign_in @agent.user
      end

      it "should return a successful response" do
        get :index, params: { pharmacy_id: @buying_pharmacy.id }
        expect(response.status).to eq 200
      end

      it "should render the :index template" do
        get :index, params: { pharmacy_id: @buying_pharmacy.id }
        expect(response.body).to render_template 'marketplace/orders/index'
      end

      it "should include any placed orders for the pharmacy" do
        get :index, params: { pharmacy_id: @buying_pharmacy.id }
        expect(response.body).to include @order.reference
        expect(response.body).to include @order.product_names
      end

      it "should not include any in-progress orders for the pharmacy" do
        @order.update_column(:state, Marketplace::Order::State::IN_PROGRESS)
        get :index, params: { pharmacy_id: @buying_pharmacy.id }
        expect(response.body).not_to include @payment.reference
      end

      describe "from another pharmacy" do
        before :each do
          sign_in @other_agent.user
        end

        it "should not include any placed orders from another pharmacy" do
          get :index, params: { pharmacy_id: @other_agent.pharmacy.id }
          expect(response.body).not_to include @payment.reference
        end

        describe "accessing purchases for a different pharmacy" do
          it "should redirect the user to the root path" do
            get :index, params: { pharmacy_id: @buying_pharmacy.id }
            expect(response).to redirect_to root_path
          end

          it "should redirect the user to the root path" do
            get :index, params: { pharmacy_id: @buying_pharmacy.id }
            expect(flash[:error]).to eq I18n.t('errors.access_denied')
          end
        end
      end
    end
  end
end
