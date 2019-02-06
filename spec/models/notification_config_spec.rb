require 'rails_helper'

describe NotificationConfig do
  [ :profile,
    :purchase_emails,
    :purchase_texts,
    :purchase_site_notifications,
    :sale_emails,
    :sale_texts,
    :sale_site_notifications ].each do |method|
    it "should respond to :#{method}" do
      expect(NotificationConfig.new).to respond_to method
    end
  end
end
