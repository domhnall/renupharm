class PagesController < ApplicationController
  def index
    @transparent_nav = true
    @sales_contact = Sales::Contact.new
  end

  def privacy_policy
  end

  def cookies_policy
  end
end
