class AuthenticatedController < ApplicationController
  layout 'dashboards'
  before_action :authenticate_user!
  before_action :create_order!

  private

  def create_order!
    return unless current_user.pharmacy?
    current_user.create_order!
  end
end
