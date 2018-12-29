require 'rest_client'

module Adyen
  class PaymentGateway
    attr_reader :merchant_account

    def initialize(credentials={})
      raise Adyen::Error::UsernameNotSupplied if credentials[:api_username].blank?
      raise Adyen::Error::PasswordNotSupplied if credentials[:api_password].blank?
      raise Adyen::Error::UrlNotSupplied if credentials[:api_url].blank?
      @username         = credentials[:api_username]
      @password         = credentials[:api_password]
      @url              = credentials[:api_url]
      @merchant_account = credentials[:merchant_account]
      @resource         = RestClient::Resource.new(@url, @username, @password)
    end

    def purchase(request = nil)
      submit(request, Adyen::InitialPurchaseRequest, Adyen::PurchaseResponse)
    end

    def purchase_subscription(request = nil)
      submit(request, Adyen::RecurringPurchaseRequest, Adyen::PurchaseResponse)
    end

    def list_recurring(request = nil)
      submit(request, Adyen::ListRecurringRequest, Adyen::ListRecurringResponse)
    end

    def disable_recurring(request = nil)
      submit(request, Adyen::DisableRecurringRequest, Adyen::DisableRecurringResponse)
    end

    private

    def submit(request, request_type, response_type)
      raise Adyen::Error::ApiRequest, "Need to supply a request object" unless request
      raise Adyen::Error::ApiRequest, "Need to supply an #{request_type.to_s}" unless request.is_a?(request_type)
      response_string = @resource.post request.build_adyen_params
      response_type.new(response_string)
    end
  end
end
