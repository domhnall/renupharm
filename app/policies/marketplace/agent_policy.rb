class Marketplace::AgentPolicy < AuthenticatedApplicationPolicy
  def show?
    (pharmacy.active? && agent.active?) || user.admin? || user.pharmacy==pharmacy
  end

  def create?
    user.admin? || (user.superintendent? && user.pharmacy==pharmacy && pharmacy.active?)
  end

  def update?
    create?
  end

  private

  def agent
    record
  end

  def pharmacy
    agent.pharmacy
  end
end
