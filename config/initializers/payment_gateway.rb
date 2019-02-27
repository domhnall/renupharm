Stripe.api_key = Rails.application.credentials.stripe[:secret]
PAYMENT_GATEWAY = PaymentGateway::Gateway
