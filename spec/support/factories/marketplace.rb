module Factories
  module Marketplace
    include Factories::Base

    def create_pharmacy(attrs = {})
      ::Marketplace::Pharmacy.create({
        name: attrs.fetch(:name){ "Larusso's Pharmacy" },
        address_1: attrs.fetch(:address_1){ "99 Bun Road" },
        address_2: attrs.fetch(:address_2){ "Caketown" },
        address_3: attrs.fetch(:address_3){ "Dundalk" },
        email: attrs.fetch(:email){ "damo@renupharm.ie" },
        telephone: attrs.fetch(:telephone){ "01234567" },
        active: attrs.fetch(:active){ true }
      }).tap do |pharmacy|
        pharmacy.image.attach(io: File.open("#{Rails.root}/spec/support/images/store_1.jpeg"), filename: "larusso.jpeg")
        pharmacy.save!
      end.reload
    end

    def create_larussos
      create_pharmacy
    end

    def create_lawrences
      create_pharmacy({
        name: "Lawrence's Pharmacy",
        address_1: "8 Mill St",
        address_2: "Hilltown",
        address_3: "Athlone",
        email: "conla@renupharm.ie",
        telephone: "07654321"
      }).tap do |pharmacy|
        pharmacy.image.attach(io: File.open("#{Rails.root}/spec/support/images/store_2.jpeg"), filename: "lawrence.jpeg")
      end
    end

    def create_agent(attrs = {})
      attrs.fetch(:pharmacy){ create_pharmacy }.agents.create({
        user: attrs.fetch(:user){ create_user(email: "agent@renupharm.ie") },
        active: attrs.fetch(:active){ true }
      })
    end

    def create_product(attrs = {})
      attrs.fetch(:pharmacy){ create_pharmacy }.products.create({
        name: attrs.fetch(:name){ "Paracetomol" },
        unit_size: attrs.fetch(:unit_size){ "80 capsules" },
        description: attrs.fetch(:description){ "Some popular drug that we want to populate on our database" },
        active: attrs.fetch(:active){ true }
      })
    end

    def create_listing(attrs = {})
      attrs.fetch(:product){ create_product(attrs) }.listings.create({
        quantity: attrs.fetch(:quantity){ 1 },
        price_cents: attrs.fetch(:price_cents){ 8499 },
        expiry: attrs.fetch(:expiry){ Date.today+24.days },
        active: attrs.fetch(:active){ true }
      })
    end

    def create_order(attrs = {})
      attrs.fetch(:agent){ create_agent }.orders.create({
        state: attrs.fetch(:state){ Marketplace::Order::State::IN_PROGRESS },
      }).tap do |order|
        order.line_items.create({
          listing: attrs.fetch(:listing){ create_listing }
        })
      end.reload
    end
  end
end
