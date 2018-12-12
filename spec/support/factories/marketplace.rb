module Factories
  module Marketplace
    include Factories::Base

    def create_pharmacy(attrs = {})
      ::Marketplace::Pharmacy.create({
        name: attrs.fetch(:name){ Faker::Company.unique.name },
        address_1: attrs.fetch(:address_1){ Faker::Address.street_address },
        address_2: attrs.fetch(:address_2){ nil },
        address_3: attrs.fetch(:address_3){ Faker::Address.city },
        email: attrs.fetch(:email){ Faker::Internet.unique.email },
        telephone: attrs.fetch(:telephone){ "01234567" },
        active: attrs.fetch(:active){ true }
      }).tap do |pharmacy|
        if attrs.fetch(:with_images, false)
          begin
            #img = open(Faker::Avatar.image)
            img = generate_image
            pharmacy.image.attach(io: img, filename: "#{pharmacy.name.downcase.underscore}.jpeg") if img
            pharmacy.save!
          rescue OpenURI::HTTPError, URI::InvalidURIError, Net::ReadTimeout
          end
        end
      end.reload
    end

    def create_larussos
      create_pharmacy({
        name: "Larusso's Pharmacy",
        address_1: "99 Bun Road",
        address_2: "Caketown",
        address_3: "Dundalk",
        email: "damo@renupharm.ie",
        telephone: "07654321"
      }).tap do |pharmacy|
        pharmacy.image.attach(io: File.open("#{Rails.root}/spec/support/images/store_1.jpeg"), filename: "larusso.jpeg")
      end
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
        user: attrs.fetch(:user){ create_user(email: Faker::Internet.unique.email) },
        active: attrs.fetch(:active){ true }
      })
    end

    def create_product(attrs = {})
      pharmacy = attrs.fetch(:pharmacy){ create_pharmacy }
      ::Marketplace::Product.create({
        pharmacy: pharmacy,
        name: attrs.fetch(:name){ Faker::Science.unique.element },
        unit_size: attrs.fetch(:unit_size){ "80 capsules" },
        description: attrs.fetch(:description){ Faker::Lorem.paragraph(3) },
        active: attrs.fetch(:active){ true }
      }).tap do |product|
        if attrs.fetch(:with_images, false)
          begin
            #img = open(Faker::Avatar.image(product.name.downcase, "50x50", "jpg"))
            img = generate_image(product.name.downcase)
            product.images.attach(io: img, filename: product.name) if img
            product.save!
          rescue OpenURI::HTTPError, URI::InvalidURIError, Net::ReadTimeout
          end
        end
      end
    end

    def create_listing(attrs = {})
      attrs.fetch(:product){ create_product(attrs) }.listings.create({
        quantity: attrs.fetch(:quantity){ 1 },
        price_cents: attrs.fetch(:price_cents){ (8000+rand*7000).floor },
        expiry: attrs.fetch(:expiry){ Date.today+24.days },
        active: attrs.fetch(:active){ true },
        purchased_at: attrs.fetch(:purchased_at){ nil }
      })
    end

    def create_order(attrs = {})
      attrs.fetch(:agent){ create_agent }.orders.create({
        state: attrs.fetch(:state){ ::Marketplace::Order::State::IN_PROGRESS },
      }).tap do |order|
        order.line_items.create({
          listing: attrs.fetch(:listing){ create_listing }
        })
      end.reload
    end

    def create_credit_card(attrs = {})
      attrs.fetch(:pharmacy){ create_pharmacy }.credit_cards.create({
        number: "1111",
        expiry_month: 10,
        expiry_year: 2020,
        holder_name: Faker::Name.name,
        brand: "Mastercard",
        email: Faker::Internet.email,
        recurring_detail_reference: SecureRandom.hex
      })
    end

    def create_payment(attrs = {})
      selling_pharmacy = create_pharmacy.tap do |pharmacy|
        pharmacy.agents.create(user: create_user)
      end
      listing = create_listing(pharmacy: selling_pharmacy)

      buying_pharmacy = create_pharmacy.tap do |pharmacy|
        agent = pharmacy.agents.create(user: create_user)
        agent.orders.create(state: ::Marketplace::Order::State::COMPLETED).tap do |order|
          order.line_items.create(listing: listing)
        end
      end
      credit_card = create_credit_card(pharmacy: buying_pharmacy)


      credit_card.payments.create({
        order: buying_pharmacy.orders.first,
        amount_cents: 9999,
        currency_code: "EUR",
      })
    end

    def generate_image(name = Faker::Lorem.characters(8))
      Timeout::timeout(5) do
        open(Faker::Avatar.image(name, "250x250", "jpg"))
      end
    rescue
      nil
    end
  end
end
