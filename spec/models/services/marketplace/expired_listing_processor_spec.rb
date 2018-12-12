require 'rails_helper'

describe Services::Marketplace::ExpiredListingProcessor do
  include Factories::Marketplace

  class DummyAdminMailer
    def self.batch_error(message: nil, backtrace: nil)
      OpenStruct.new(deliver_later: "Done")
    end
  end

  [ :date,
    :min_expiry_days,
    :call ].each do |method|
    it "should respond to the method :#{method}" do
      expect( Services::Marketplace::ExpiredListingProcessor.new ).to respond_to method
    end
  end

  before :all do
    @today                 = Date.today
    @next_week             = @today+7.days
    @safe_listing          = create_listing(expiry: @next_week+8.days)
    @near_expiry_listing_1 = create_listing(expiry: @next_week+3.days)
    @near_expiry_listing_2 = create_listing(expiry: @next_week+6.days)
    @purchased_listing     = create_listing(expiry: @next_week+1.days, purchased_at: @today-14.days)
  end


  describe "instantiation" do
    it "should set the :date to the value supplied" do
      expect( Services::Marketplace::ExpiredListingProcessor.new(date: @next_week).date ).to eq @next_week
    end

    it "should set the :date to be current date when not supplied" do
      expect( Services::Marketplace::ExpiredListingProcessor.new.date ).to eq @today
    end

    it "should set the :min_expiry_days to the value specified" do
      expect( Services::Marketplace::ExpiredListingProcessor.new(min_expiry_days: 14).min_expiry_days ).to eq 14
    end

    it "should set the :min_expiry_days to 7 when not specified" do
      expect( Services::Marketplace::ExpiredListingProcessor.new.min_expiry_days ).to eq 7
    end
  end

  describe "instance method" do
    before :all do
      @service = Services::Marketplace::ExpiredListingProcessor.new(date: @next_week, admin_mailer_class: DummyAdminMailer)
    end

    describe "#call" do
      it "should return a Services::Response object" do
        expect(@service.call).to be_a Services::Response
      end

      it "should mark listings with near-expiry as inactive" do
        orig_count = Marketplace::Listing.active_listings.count
        expect(Marketplace::Listing.active_listings.map(&:id)).to include @near_expiry_listing_1.id
        expect(Marketplace::Listing.active_listings.map(&:id)).to include @near_expiry_listing_2.id
        @service.call
        expect(Marketplace::Listing.active_listings.count).to eq orig_count-2
        expect(Marketplace::Listing.active_listings.map(&:id)).not_to include @near_expiry_listing_1.id
        expect(Marketplace::Listing.active_listings.map(&:id)).not_to include @near_expiry_listing_2.id
      end

      it "should not deactivate listings that are not near expiry" do
        expect(Marketplace::Listing.active_listings.map(&:id)).to include @safe_listing.id
        @service.call
        expect(Marketplace::Listing.active_listings.map(&:id)).to include @safe_listing.id
      end

      it "should not update listings that have already been purchased" do
        expect(Marketplace::Listing.where(active: true).map(&:id)).to include @purchased_listing.id
        @service.call
        expect(Marketplace::Listing.where(active: true).map(&:id)).to include @purchased_listing.id
      end

      describe "when error is thrown" do
        describe "where error is a Service::Error" do
          before :each do
            allow_any_instance_of(::Marketplace::Listing).to receive(:save!).and_raise(Services::Error, "Dummy error")
          end

          it "should not raise an error" do
            expect{ @service.call }.not_to raise_error
          end

          it "should return a response to the caller" do
            expect(@service.call).to be_a Services::Response
          end

          it "should enrich the response with the error" do
            expect(@service.call.errors).not_to be_empty
          end

          it "should not trigger a batch error email" do
            expect(DummyAdminMailer).not_to receive(:batch_error)
            @service.call
          end
        end

        describe "where error is of some other type" do
          before :each do
            allow_any_instance_of(::Marketplace::Listing).to receive(:save!).and_raise(StandardError, "Dummy error")
          end

          it "should trigger a batch error email" do
            expect(DummyAdminMailer).to receive(:batch_error).with(hash_including(message: "Dummy error")).and_call_original
            expect{ @service.call }.to raise_error(Services::Error)
          end

          it "should not return a response but should throw an error" do
            expect{ @service.call }.to raise_error(Services::Error)
          end
        end
      end
    end
  end
end
