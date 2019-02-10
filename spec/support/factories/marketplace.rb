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
      pharmacy = attrs.fetch(:pharmacy){ create_pharmacy }
      pharmacy.agents.create({
        user: attrs.fetch(:user){ create_user(email: Faker::Internet.unique.email) },
        active: attrs.fetch(:active){ true },
        superintendent: attrs.fetch(:superintendent){ pharmacy.agents.superintendent.empty? }
      })
    end

    def create_product(attrs = {})
      pharmacy = attrs.fetch(:pharmacy){ create_pharmacy }
      ::Marketplace::Product.create({
        pharmacy: pharmacy,
        name: attrs.fetch(:name){ Faker::Science.unique.element },
        pack_size: attrs.fetch(:pack_size){ "80" },
        active_ingredient: attrs.fetch(:description){ Faker::Science.element },
        form: attrs.fetch(:form){ "capsule" },
        manufacturer: attrs.fetch(:manufacturer){ Faker::Company.name },
        strength: attrs.fetch(:strength){ "100" },
        active: attrs.fetch(:active){ true }
      }).tap do |product|
        if attrs.fetch(:with_images, false)
          begin
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
        batch_number: attrs.fetch(:batch_number){ Faker::Number.leading_zero_number(10) },
        seller_note: attrs.fetch(:seller_note){ Faker::Lorem.paragraph(3) },
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
        recurring_detail_reference: SecureRandom.hex,
        default: attrs.fetch(:default){ false }
      })
    end

    def create_payment(attrs = {})
      selling_pharmacy = create_pharmacy.tap do |pharmacy|
        pharmacy.agents.create(user: create_user, superintendent: true)
      end
      listing = create_listing(pharmacy: selling_pharmacy)

      buying_pharmacy = create_pharmacy.tap do |pharmacy|
        agent = pharmacy.agents.create(user: create_user, superintendent: true)
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
