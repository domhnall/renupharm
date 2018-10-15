class AuthenticatedController < ApplicationController
  layout 'dashboards'
  before_action :authenticate_user!
end
