class RecaptchaResponseVerifier
  VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify".freeze

  attr_reader :site_key, :secret_key

  def initialize(site_key: nil, secret_key: nil)
    raise ArgumentError, "You must supply :site_key and :secret_key" unless (site_key && secret_key)
    @site_key = site_key
    @secret_key = secret_key
  end

  def verify(res)
    JSON.parse(HTTP.post(VERIFY_URL, form: { secret: secret_key, response: res }))["success"]
  end
end
