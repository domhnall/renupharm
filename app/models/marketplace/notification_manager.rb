class Marketplace::NotificationManager
  module Event
    PURCHASE = "purchase"
    SALE = "sale"
  end

  attr_reader :user

  def self.notify(user, event, data)
    self.new(user).notify(event, data)
  end

  def initialize(user)
    raise ArgumentError unless user && user.is_a?(User)
    @user = user.becomes(Users::Agent)
  end

  def notify(event, data)
    case event
    when Event::PURCHASE
      notify_purchase(data[:order])
    when Event::SALE
      notify_sale(data[:order])
    else
      raise NotImplementedError, "Marketplace::NotificationManager does not know how to handle #{event}"
    end
  end

  private

  def notify_purchase(order)
    if user.purchase_emails?
      Marketplace::OrderMailer.purchase_notification(agent_id: agent.id, order_id: order.id).deliver_later
    end

    if user.purchase_texts?
      Services::Marketplace::SendSms.new(recipient: user, message: build_purchase_message(order)).call
    end

    if user.purchase_site_notifications?
      Services::Marketplace::CreateNotification.new(recipient: user, message: build_purchase_notification(order)).call
    end
  end

  def notify_sale(order)
    if user.sale_emails?
      Marketplace::OrderMailer.sale_notification(agent_id: agent.id, order_id: order.id).deliver_later
    end

    if user.sale_texts?
      Services::Marketplace::SendSms.new(recipient: user, message: build_sale_message(order)).call
    end

    if user.sale_site_notifications?
      Services::Marketplace::CreateNotification.new(recipient: user, message: build_sale_notification(order)).call
    end
  end

  def build_purchase_message(order)
    "User X from your pharmacy has just purchased Y on RenuPharm. Visit www.renupharm.ie to see order details and track delivery."
  end

  def build_sale_message(order)
    "A user has just purchased X from your pharmacy on RenuPharm. Please prep for collection."
  end

  def build_purchase_notification(order)
    "Dummy purchase notification"
  end

  def build_sale_notification(order)
    "Dummy sale notification"
  end

  def agent
    @_agent ||= user.agent
  end
end
