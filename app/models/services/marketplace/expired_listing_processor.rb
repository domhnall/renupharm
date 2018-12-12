class Services::Marketplace::ExpiredListingProcessor

  attr_reader :date, :min_expiry_days, :admin_mailer_class, :response

  def initialize(date: Date.today, min_expiry_days: Marketplace::Listing::ACCEPTABLE_EXPIRY_DAYS, admin_mailer_class: Admin::ErrorMailer)
    @date               = date
    @min_expiry_days    = min_expiry_days
    @admin_mailer_class = admin_mailer_class
    @errors             = []
    @response           = Services::Response.new(errors: @errors)
  end

  def call
    fetch_listings_for_deactivation.each do |listing|
      listing.active = false
      listing.save!
    end
    response
  rescue Services::Error => e
    @errors << e
    response
  rescue Exception => e
    admin_mailer_class.batch_error(message: e.message, backtrace: e.backtrace).deliver_later
    raise Services::Error, I18n.t("general.error")
  end

  private

  def fetch_listings_for_deactivation
    ::Marketplace::Listing.active_listings.where("expiry < ?", date+min_expiry_days.days)
  end
end
