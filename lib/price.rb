class Price
  attr_accessor :price_cents, :currency_code

  def initialize(price_cents, currency_code = "EUR")
    raise ArgumentError unless price_cents
    @price_cents = price_cents.to_i
    @currency_code = currency_code
  end

  def currency_symbol
    { "GBP" => "£",
      "USD" => "$",
      "EUR" => "€" }.fetch(currency_code, "€")
  end

  def price_major
    decimal_price.split('.')[0]
  end

  def price_minor
    decimal_price.split('.')[1]
  end

  def display_price
    "#{currency_symbol}#{decimal_price}"
  end

  def +(price)
    raise ArgumentError, "Prices must be of same currency" unless self.currency_code==price.currency_code
    Price.new(self.price_cents+price.price_cents, self.currency_code)
  end

  def -(price)
    raise ArgumentError, "Prices must be of same currency" unless self.currency_code==price.currency_code
    Price.new(self.price_cents-price.price_cents, self.currency_code)
  end

  private

  def decimal_price
    sprintf("%0.2f", price_cents/100.to_f)
  end
end
