class DashboardsController < AuthenticatedController
  def show
    get_data_for_admin_charts if current_user.admin?
    get_data_for_pharmacy_agent if current_user.pharmacy?
  end

  private

  def get_data_for_admin_charts
    @total_sales_pharmacies     = Sales::Pharmacy.count
    @pharmacies_chart_presenter = Presenters::ChartPresenter.new(get_week_labels).tap do |presenter|
      presenter.add_dataset("Pharmacies added", pharmacies_by_week)
    end

    @total_survey_responses     = SurveyResponse.count
    @survey_chart_presenter     = Presenters::ChartPresenter.new(get_week_labels).tap do |presenter|

      presenter.add_dataset("Surveys completed", survey_responses_by_week)
    end

    @total_outreach             = Sales::Pharmacy.joins(:comments).distinct.count
    @outreach_chart_presenter   = Presenters::ChartPresenter.new(get_week_labels).tap do |presenter|
      presenter.add_dataset("Contacted", pharmacies_contacted_by_week)
    end
  end

  def get_data_for_pharmacy_agent
    @total_sales_count           = policy_scope(Marketplace::Sale).count
    @total_sales_value           = Price.new(policy_scope(Marketplace::Sale).joins(:payment).sum("marketplace_payments.amount_cents"))
    @total_purchases_count       = policy_scope(Marketplace::Purchase).count
    @total_purchases_value       = Price.new(policy_scope(Marketplace::Purchase).joins(:payment).sum("marketplace_payments.amount_cents"))
    @total_active_listings_count = pharmacy.listings.active_listings.count
    @total_active_listings_value = Price.new(pharmacy.listings.active_listings.sum(:price_cents))

    # Recent transactions
    @recent_purchases = policy_scope(Marketplace::Purchase).limit(5)
    @recent_sales     = policy_scope(Marketplace::Sale).limit(5)
    @recent_listings  = pharmacy.listings.order(created_at: :desc).limit(5)
  end

  def get_week_endings
    @_week_endings ||= (0..5).to_a.reverse
    .map{ |i| (Time.now - i.weeks).end_of_week }
  end

  def get_week_labels
    get_week_endings.map{ |d| "w/e #{d.strftime("%Y-%m-%d")}" }
  end

  def pharmacies_by_week
    get_week_endings.map do |end_date|
      Sales::Pharmacy.where(created_at: (end_date-7.days)..end_date).count
    end
  end

  def survey_responses_by_week
    get_week_endings.map do |end_date|
      SurveyResponse.where(created_at: (end_date-7.days)..end_date).count
    end
  end

  def pharmacies_contacted_by_week
    get_week_endings.map do |end_date|
      Sales::Pharmacy.joins(:comments).where(comments: {created_at: (end_date-7.days)..end_date}).distinct.count
    end
  end

  def pharmacy
    current_user.pharmacy
  end
end
