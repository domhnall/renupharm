
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
        strength: "5mg",
        form: "hard_capsules",
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
            Aenean quis est massa. Donec eleifend nibh odio, id egestas eros pretium egestas.
            Nulla ligula nibh, tincidunt a arcu et, semper hendrerit orci. Quisque non lacus rhoncus,
            pulvinar ligula eget, iaculis nulla. Donec et laoreet lacus.
          DESC
        })
        product.listings.create({
          quantity: 4,
          price_cents: 10000,
          expiry: Date.today+2.months,
          batch_number: "90809083",
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

      @wart_remedy = pharmacy.products.create({
        name: "Hog Wart",
        active_ingredient: "Dumbledore",
        strength: "10mg",
        form: "hard_capsules",
        pack_size: "80",
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/tablet_bottle.jpeg"), filename: "tablet_bottle.jpeg")
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/tablets_spilled.jpeg"), filename: "tablets_spilled.jpeg")
        product.listings.create({
          quantity: 10,
          price_cents: 9499,
          expiry: Date.today+6.months,
          batch_number: "90809080",
          seller_note: <<-DESC,
            In sit amet pharetra lorem. Phasellus eleifend lectus non
            molestie laoreet. Quisque ut lectus vehicula, vestibulum est at,
            mollis lectus. Phasellus semper vel turpis quis sollicitudin.
            Phasellus id molestie nisi. Pellentesque maximus augue vel
            elementum aliquam. Nam non turpis lobortis metus molestie
            interdum nec et nunc. Vestibulum odio nunc, pulvinar ut sem
            quis, tempor egestas urna. Suspendisse potenti. Curabitur
            lobortis vehicula lectus sit amet vulputate. Mauris mollis
            turpis eget metus pretium lobortis. Aliquam ut pharetra ipsum.
            In hac habitasse platea dictumst. Cras lobortis, sem ut
            sodales consectetur, orci massa ultricies felis, non hendrerit
            ante metus quis arcu.
          DESC
        })
      end

      @opdivo = pharmacy.products.create({
        name: "Opdivo",
        active_ingredient: "Nivolumab",
        strength: "2mg",
        form: "soft_capsules",
        pack_size: "200"
      }).tap do |product|
        product.images.attach(io: File.open("#{Rails.root}/spec/support/images/opdivo.jpeg"), filename: "opdivo.jpeg")
        product.listings.create({
          quantity: 6,
          price_cents: 14499,
          expiry: Date.today+9.months,
          batch_number: "90809081",
          seller_note: <<-DESC,
            Cras bibendum pretium accumsan. Vivamus tellus metus, ullamcorper
            ut tincidunt vulputate, imperdiet et nisi. Duis sed nunc ac
            lorem eleifend interdum vitae nec felis. Mauris elementum
            fringilla accumsan. Nunc porttitor mauris faucibus ex eleifend,
            eget sagittis ante ornare. Cras lectus metus, dignissim non porta
            a, tristique eu sem. Curabitur mollis commodo elit, sit amet
            vestibulum risus posuere ac. Praesent ac ligula vitae dolor
            malesuada tempus. Maecenas vehicula laoreet ex. Suspendisse
            placerat blandit malesuada. Curabitur interdum nisi sed augue
            vehicula, sed tincidunt mauris imperdiet.
          DESC
        })
      end
    end

    # Create buying pharmacy
    lawrences = create_lawrences.tap do |pharmacy|
      pharmacy.agents.create(user: johnny, superintendent: true).tap do |agent|
        agent.orders.create(state: Marketplace::Order::State::IN_PROGRESS).tap do |order|
          order.line_items.create(listing: @wart_remedy.listings.first)
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
