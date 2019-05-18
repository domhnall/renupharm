
task dev_environment: [:environment] do
  raise StandardError, "Cannot execute on #{Rails.env}" unless Rails.env.development? #if Rails.env.production?
end

namespace :renupharm do
  desc "Set up dev database"
  task setup_dev: [:dev_environment, "db:drop", "db:create", "db:migrate", "db:seed"] do
    Dir["#{Rails.root}/spec/support/factories/*.rb"].each {|file| require file }
    include Factories::Base
    include Factories::Marketplace

    # Create users
    daniel = create_daniel
    johnny = create_johnny

    # Create selling pharmacy
    larussos = create_larussos.tap do |pharmacy|
      pharmacy.agents.create(user: daniel, superintendent: true)

      @valium = pharmacy.products.create({
        name: "Valium",
        active_ingredient: "Diazepam",
        strength: "5.0",
        form: "capsule",
        pack_size: "40"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/capsules_loose.jpeg"), filename: "capsules_loose.jpeg")
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/pills_loose.jpeg"), filename: "pills_loose.jpeg")
        product.listings.create({
          quantity: 4,
          price_cents: 12000,
          expiry: Date.today+3.months,
          batch_number: "90809082",
          seller_note: <<-DESC,
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum nec erat leo.
            Morbi lorem purus, sagittis non nunc nec, tristique sollicitudin nunc. Etiam ex justo,
            fermentum quis iaculis quis, fringilla scelerisque libero.
            Aenean quis est massa.
          DESC
        })
        product.listings.create({
          quantity: 4,
          price_cents: 10000,
          expiry: Date.today+2.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            The path of the righteous man is beset on all sides by the
            Inequities of the selfish and the tyranny of evil men
            Blessed is he who, in the name of charity and good will
            shepherds the weak through the valley of darkness
            for he is truly his brother's keeper and the finder of lost children
            And I will strike down upon thee with great vengeance and furious
            Anger those who attempt to poison and destroy my brothers
            And you will know
            My name is the Lord when I lay my vengeance upon thee
          DESC
        })
      end

      @opdivo = pharmacy.products.create({
        name: "Opdivo",
        active_ingredient: "Nivolumab",
        strength: "2.0",
        form: "tablet",
        pack_size: "200"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/opdivo.jpeg"), filename: "opdivo.jpeg")
        product.listings.create({
          quantity: 6,
          price_cents: 14499,
          expiry: Date.today+9.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Cras bibendum pretium accumsan. Vivamus tellus metus, ullamcorper
            ut tincidunt vulputate, imperdiet et nisi. Duis sed nunc ac
            lorem eleifend interdum vitae nec felis. Mauris elementum
            fringilla accumsan.
          DESC
        })
      end

      @pradaxa = pharmacy.products.create({
        name: "Pradaxa",
        active_ingredient: "Dabigatran etexilate",
        strength: "110",
        form: "capsule",
        manufacturer: "Boehringer Ingelheim",
        pack_size: "60"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/pradaxa.jpg"), filename: "pradaxa.jpg")
        product.listings.create({
          quantity: 1,
          price_cents: 3499,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Previous active patient has increased strength
          DESC
        })
      end

      @cyclogest = pharmacy.products.create({
        name: "Cyclogest",
        active_ingredient: "Progesterone",
        strength: "400.0",
        form: "pessary",
        pack_size: "12"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/cyclogest.png"), filename: "cyclogest.png")
        product.listings.create({
          quantity: 6,
          price_cents: 1499,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            No forseeable usage
          DESC
        })
      end

      @soolantro = pharmacy.products.create({
        name: "Soolantro",
        active_ingredient: "Ivermectin",
        strength: "1.0",
        form: "cream",
        manufacturer: "Calderma",
        pack_size: "12"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/soolantra.png"), filename: "soolantra.png")
        product.listings.create({
          quantity: 6,
          price_cents: 2499,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end

      @nutrison = pharmacy.products.create({
        name: "Nutrison Multifibre",
        strength: 1.03,
        form: "nutritional_liquid",
        manufacturer: "Nutricia",
        pack_size: "1000"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/nutrison.png"), filename: "nutrison.png")
        product.listings.create({
          quantity: 10,
          price_cents: 8000,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end

      @coloplast = pharmacy.products.create({
        name: "Simpla Urinary Leg Collection Bag",
        form: "leg_bag",
        pack_size: "10",
        volume: "500",
        manufacturer: "Coloplast"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/coloplast.png"), filename: "coloplast.png")
        product.listings.create({
          quantity: 8,
          price_cents: 2400,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end

      @novorapid = pharmacy.products.create({
        name: "Novorapid Flexpen",
        active_ingredient: "Insulin Aspart",
        strength: 3.5,
        form: "injectable",
        manufacturer: "Nordisk",
        pack_size: 5
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/novorapid.png"), filename: "novorapid.png")
        product.listings.create({
          quantity: 5,
          price_cents: 7500,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end

      @xalatan = pharmacy.products.create({
        name: "Xalatan",
        active_ingredient: "Latanoprost",
        form: "drops",
        manufacturer: "Pfizer",
        pack_size: "2.5"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/xalatan.png"), filename: "xalatan.png")
        product.listings.create({
          quantity: 1,
          price_cents: 1500,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end

      @cosopt_2_0 = pharmacy.products.create({
        name: "Cosopt (Preservative Free)",
        active_ingredient: "Dorzolamide/Timolol",
        strength: 2.0,
        form: "sdu",
        manufacturer: "Merck Sharp",
        pack_size: "60"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/cosopt.png"), filename: "cosopt.png")
        product.listings.create({
          quantity: 1,
          price_cents: 2000,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end

      @cosopt_0_5 = pharmacy.products.create({
        name: "Cosopt (Preservative Free)",
        active_ingredient: "Dorzolamide/Timolol",
        strength: 0.5,
        form: "sdu",
        manufacturer: "Merck Sharp",
        pack_size: "60"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/cosopt.png"), filename: "cosopt.png")
        product.listings.create({
          quantity: 1,
          price_cents: 1500,
          expiry: Date.today+(1..9).to_a.sample.months,
          batch_number: '%06i' % (rand*1000000).floor,
          seller_note: <<-DESC,
            Excess stock
          DESC
        })
      end
    end

    # Create buying pharmacy
    lawrences = create_lawrences.tap do |pharmacy|
      pharmacy.agents.create(user: johnny, superintendent: true).tap do |agent|
        [@valium, @cosopt_0_5].each do |product|
          create_completed_order(agent: agent, listing: product.listings.first)
        end
        agent.orders.create(state: Marketplace::Order::State::IN_PROGRESS).tap do |order|
          order.line_items.create(listing: @xalatan.listings.first)
        end
      end
    end
  end

  task populate_marketplace: [:dev_environment] do
    include Factories::Marketplace
    5.times do
      create_pharmacy.tap do |pharmacy|
        10.times{ create_listing(pharmacy: pharmacy, with_images: true) }
      end
    end
    Rake::Task["sunspot:reindex"].invoke
  end

end
