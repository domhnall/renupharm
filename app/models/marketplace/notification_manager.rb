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

    if user.telephone.present? && user.purchase_texts?
      Services::SendSms.new(recipient: user, message: build_purchase_sms(order)).call
    end

    if user.purchase_site_notifications?
      Services::SendWebPushNotification.new(
        recipient: user,
        title: I18n.t("web_push_notification.title.purchase_alert"),
        message: build_purchase_notification(order),
        options: {
          actions: [{ action: "review-purchase-#{order.id}", title: I18n.t("web_push_notification.actions.purchase") }]
        }
      ).call
    end
  end

  def notify_sale(order)
    if user.sale_emails?
      Marketplace::OrderMailer.sale_notification(agent_id: agent.id, order_id: order.id).deliver_later
    end

    if user.telephone.present? && user.sale_texts?
      Services::SendSms.new(recipient: user, message: build_sale_sms(order)).call
    end

    if user.sale_site_notifications?
      Services::SendWebPushNotification.new(
        recipient: user,
        title: I18n.t("web_push_notification.title.sale_alert"),
        message: build_sale_notification(order),
        options: {
          actions: [{ action: "review-sale-#{order.id}", title: I18n.t("web_push_notification.actions.sale") }]
        }
      ).call
    end
  end

  def build_purchase_sms(order)
    [ base_purchase_message(order),
      "Visit www.renupharm.ie to see order details and track delivery."].join(" ")
  end

  def build_sale_sms(order)
    [ base_sale_message(order),
      "Visit www.renupharm.ie to see order details and arrange delivery."].join(" ")
  end

  def build_purchase_notification(order)
    base_purchase_message(order)
  end

  def build_sale_notification(order)
    base_sale_message(order)
  end

  def base_purchase_message(order)
    if order.line_items.size==1
      "User #{order.user.full_name} has just purchased #{order.line_items.first.product_name}."
    else
      "User #{order.user.full_name} has just purchased multiple products."
    end
  end

  def base_sale_message(order)
    if order.line_items.size==1
      "A user has just purchased #{order.line_items.first.product_name} from your pharmacy."
    else
      "A user has just purchased multiple products from your pharmacy."
    end
  end

  def agent
    @_agent ||= user.agent
  end
end
