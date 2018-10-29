class Admin::Marketplace::AgentsController < AuthenticatedController
  def new
    @pharmacy = pharmacy
    @agent = pharmacy.agents.build
    authorize @agent
  end

  def create
  end

  def edit
    @pharmacy = pharmacy
    @agent = pharmacy.agents.build
    authorize @agent
  end

  def update
  end

  private

  def pharmacy
    @_pharmacy ||= ::Marketplace::Pharmacy.find(params.fetch(:pharmacy_id).to_i)
  end
end
