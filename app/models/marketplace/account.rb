class Marketplace::Account
  attr_reader :pharmacy

  def initialize(pharmacy: nil)
    raise ArgumentError, "Marketplace::Account must be instantiated with a pharmacy" unless pharmacy.is_a? Marketplace::Pharmacy
    @pharmacy = pharmacy
  end

  def balance
    get_price(sales_payable)
  end

  def uncleared_earnings
    get_price(sales_uncleared)
  end

  def total_payouts_to_date(date = Time.now)
    payouts_to_date(date).map(&:price).reduce(&:+) || Price.new(0)
  end

  [:balance, :uncleared_earnings, :total_payouts_to_date].each do |method|
    define_method "display_#{method}".to_sym do
      self.send(method).display_price
    end
  end

  def sales
    Marketplace::Sale.for_pharmacy(pharmacy).completed
  end

  def purchases
    Marketplace::Purchase.for_pharmacy(pharmacy).completed
  end

  def sales_payable
    sales.cleared.not_paid_out
  end

  def sales_uncleared
    sales.not_paid_out - sales.cleared
  end

  def payouts_to_date(date = Time.now)
    pharmacy.seller_payouts.where("marketplace_seller_payouts.created_at < ?", date)
  end

  private

  def get_price(sales)
    sales.map(&:seller_earning).compact.reduce(&:+) || Price.new(0)
  end
end
