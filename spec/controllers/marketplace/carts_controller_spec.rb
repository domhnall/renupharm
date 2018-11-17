require 'rails_helper'

describe Marketplace::CartsController do
  include Factories::Marketplace

  before :all do
    @pharmacy = create_pharmacy(name: "Merdith's", email: "burgess@meredith.com")
    @user = create_user(email: "stuart@baggs.com").becomes(Users::Agent)
    @agent = @pharmacy.agents.create!(user: @user)
  end

  describe "#show" do
    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        get :show
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        sign_in @user
      end

      it "should return a successful response" do
        get :show
        expect(response.status).to eq 200
      end

      it "should render the :show template" do
        get :show
        expect(response.body).to render_template :show
      end
    end
  end

  describe "#update" do
    before :all do
      @selling_pharmacy = create_pharmacy(name: "Sally Seller's", email: "sally@sellers.com")
      @listing_1 = create_listing(name: "Toe cream", pharmacy: @selling_pharmacy)
      @listing_2 = create_listing(name: "Ear spray", pharmacy: @selling_pharmacy)
      @update_params = {
        marketplace_order: {
          state: "in_progress",
          line_items_attributes: {
            "0" => {
              marketplace_listing_id: @listing_1.id
            }
          }
        }
      }
    end

    describe "unauthenticated user" do
      it "should redirect user to the sign in path" do
        put :update, params: @update_params
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "authenticated user" do
      before :each do
        @user.reload.create_order!
        @user.reload
        sign_in @user
      end

      it "should re-render the :show template" do
        put :update, params: @update_params
        expect(response).to render_template :show
      end

      it "should set a flash message to indicate that update has been successful" do
        put :update, params: @update_params
        expect(flash[:success]).to eq I18n.t("marketplace.cart.flash.update_successful")
      end

      it "should add an appropriate line item to the user's cart" do
        expect(@user.current_order.line_items).to be_empty
        put :update, params: @update_params
        expect(@user.current_order.line_items).not_to be_empty
        expect(@user.current_order.line_items.reload.first.listing.id).to eq @listing_1.id
      end

      it "should allow deletion of line items from the user's cart" do
        line_item = @user.current_order.line_items.create(listing: @listing_2)
        expect(Marketplace::LineItem.where(id: line_item.id).count).to eq 1
        put :update, params: {
          marketplace_order: {
            state: "in_progress",
            line_items_attributes: {
              "0" => {
                marketplace_listing_id: @listing_1.id
              },
              "1" => {
                "_destroy" => true,
                id: line_item.id
              }
            }
          }
        }
        expect(@user.current_order.line_items.reload.map(&:marketplace_listing_id)).not_to include @listing_2.id
        expect(Marketplace::LineItem.where(id: line_item.id).count).to eq 0
      end

      describe "when order is updated to :placed state" do
        before :each do
          @order = @user.current_order
          @order.line_items.create(listing: @listing_1)
          @place_order_params = {marketplace_order: { state: "placed" }}
        end

        it "instantiates and calls the OrderCompleter service" do
          expect(::Services::Marketplace::OrderCompleter).to receive(:new).with(order: @order, shopper_ip: kind_of(String)).and_call_original
          put :update, params: @place_order_params
        end

        describe "on success" do
          before :each do
            @service_double = double('service', call: OpenStruct.new(success?: true))
            allow(::Services::Marketplace::OrderCompleter).to receive(:new).and_return(@service_double)
          end

          it "should re-render the :show template" do
            put :update, params: @place_order_params
            expect(response).to render_template :show
          end

          it "should set a flash message to indicate successful update" do
            put :update, params: @place_order_params
            expect(flash[:success]).to eq I18n.t("marketplace.cart.flash.update_successful")
          end
        end

        describe "on failure" do
          before :each do
            @service_double = double('service', call: OpenStruct.new(success?: false, errors: [StandardError.new("Dummy error")]))
            allow(::Services::Marketplace::OrderCompleter).to receive(:new).and_return(@service_double)
          end

          it "should re-render the :show template" do
            put :update, params: @place_order_params
            expect(response).to render_template :show
          end

          it "should set a flash message to indicate that an error has occurred" do
            put :update, params: @place_order_params
            expect(flash[:error]).to eq I18n.t("marketplace.cart.flash.error")
          end
        end
      end
    end
  end
end
