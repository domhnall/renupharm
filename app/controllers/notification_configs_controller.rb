class NotificationConfigsController < AuthenticatedController
  def show
    @notification_config = current_user.notification_config
  end

  def update
    @notification_config = current_user.notification_config
    if @notification_config.update_attributes(notification_config_params)
      redirect_to notification_config_path, flash: { success: I18n.t("notification_config.flash.update_successful") }
    else
      redirect_to notification_config_path, flash: { error: I18n.t("notification_config.flash.error") }
    end
  end

  private

  def notification_config_params
    params
    .require(:notification_config)
    .permit(:purchase_emails, :purchase_texts, :purchase_site_notifications, :sale_emails, :sale_texts, :sale_site_notifications)
  end
end
