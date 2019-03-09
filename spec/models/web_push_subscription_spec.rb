require 'rails_helper'

describe WebPushSubscription do
  include Factories::Base

  [:profile, :subscription].each do |method|
    it "it should respond to method :#{method}" do
      expect(WebPushSubscription.new).to respond_to method
    end
  end

  describe "instantiation" do
    before :all do
      @profile = create_user.profile
      @subscription_json = {
        "keys"=>{
          "auth"=>"ZRdZ9iDbURjZjnA3pCSEvQ",
          "p256dh"=>"BHiz1CA2i3aO99VBkH0FclPivQg3rl0lHEygJUypodsPg2YxcwBSNNxSK4zym33lcz7olOcmE1phjPnGt4IE06U"
        },
        "endpoint"=>"https://updates.push.services.mozilla.com/wpush/v2/gAAAAABcewZQcQelD95rMg77YGrLTZAbDZ6e0p7by9XfTt_EbN42WUSlmtcrJI2-0c9GCOeVMj2k4S2fLXN4gkHqi8OyCoEI4Q02iRXxSOKaITM4P1gC1EVysvGELdV-_G6Ab66GSh5kG6qboTIQF7fm75fYLLP2CLHlZDsO6ahhc2hPQHVvEec"
      }

      @params = { profile: @profile, subscription: @subscription_json }
    end

    it "should be valid if all required fields are supplied" do
      expect(WebPushSubscription.new(@params)).to be_valid
    end

    it "should not be valid if profile is not supplied" do
      expect(WebPushSubscription.new(@params.merge(profile: nil))).not_to be_valid
    end

    it "should not be valid if subscription JSON is not supplied" do
      expect(WebPushSubscription.new(@params.merge(subscription: nil))).not_to be_valid
    end
  end
end
