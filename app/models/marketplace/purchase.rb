class Marketplace::Purchase < Marketplace::Order
  scope :for_pharmacy, ->(pharmacy){
    joins(:pharmacy)
    .where("marketplace_pharmacies.id = ?", pharmacy.id)
    .not_in_progress
  }
end
