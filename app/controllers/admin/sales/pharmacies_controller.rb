class Admin::Sales::PharmaciesController < Admin::BaseController
  def index
    @pharmacies = ::Sales::Pharmacy.all
  end
end
