class Marketplace::Agent < ApplicationRecord
  belongs_to :user
  belongs_to :pharmacy,
    class_name: "Marketplace::Pharmacy",
    foreign_key: :marketplace_pharmacy_id,
    inverse_of: :agents

  has_many :orders,
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_agent_id,
    inverse_of: :agent

  has_one :current_order,
    ->{ where({ state: Marketplace::Order::State::IN_PROGRESS }) },
    class_name: "Marketplace::Order",
    foreign_key: :marketplace_agent_id

  has_one :profile, through: :user

  delegate :first_name,
           :surname,
           :full_name,
           :telephone,
           :email, to: :user

  delegate :name, to: :pharmacy, prefix: true

  accepts_nested_attributes_for :user

  scope :active, ->{ where(active: true) }
  scope :superintendent, ->{ where(superintendent: true) }

  validate :single_superintendent_pharmacist

  private

  def single_superintendent_pharmacist
    return unless pharmacy
    if !superintendent && pharmacy.agents.superintendent.empty?
      errors.add(:superintendent, I18n.t("marketplace.agent.errors.must_be_superintendent"))
    elsif superintendent && pharmacy.agents.superintendent.any? && pharmacy.agents.superintendent.first!=self
      errors.add(:superintendent, I18n.t("marketplace.agent.errors.already_have_superintendent"))
    end
  end
end
