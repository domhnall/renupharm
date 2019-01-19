class Marketplace::ProductForm

  FORMS = {
    capsule: {
      name: "Capsule",
      strength_unit: "mg",
      strength_required: true,
      pack_size_unit: "caps",
      pack_size_required: true
    },
    tablet: {
      name: "Tablet",
      strength_unit: "mg",
      strength_required: true,
      pack_size_unit: "tabs",
      pack_size_required: true
    },
    cream: {
      name: "Cream",
      strength_unit: "%",
      strength_required: false,
      pack_size_unit: "g",
      pack_size_required: true
    },
    pessary: {
      name: "Pessary",
      strength_unit: "mg",
      strength_required: false,
      pack_size_unit: "units",
      pack_size_required: true
    },
    suppository: {
      name: "Suppository",
      strength_unit: "mg",
      strength_required: false,
      pack_size_unit: "units",
      pack_size_required: true
    },
    eye_ointment: {
      name: "Eye ointment",
      pack_size_unit: "g",
      pack_size_required: true
    },
    drops: {
      name: "Drops",
      strength_unit: "%",
      strength_required: false,
      pack_size_unit: "ml",
      pack_size_required: true
    },
    sdu: {
      name: "Single-dosage unit",
      strength_unit: "%",
      strength_required: false,
      pack_size_unit: "doses"
    },
    oral_liquid: {
      name: "Oral liquid",
      pack_size_unit: "ml",
      pack_size_required: true
    },
    syrup: {
      name: "Syrup",
      pack_size_unit: "ml",
      pack_size_required: true
    },
    topical_liquid: {
      name: "Topical liquid/ointment",
      pack_size_unit: "ml",
      pack_size_required: true
    },
    inhalation_powder: {
      name: "Inhalation powder",
      strength_unit: "mcg",
      strength_required: true,
      pack_size_unit: "doses",
      pack_size_required: true
    },
    solution_for_inhalation: {
      name: "Solution for inhalation",
      strength_unit: "mcg",
      strength_required: true,
      pack_size_unit: "doses",
      pack_size_required: true
    },
    medicated_plaster: {
      name: "Medicated plaster",
      strength_unit: "mg",
      strength_required: true,
      pack_size_unit: "units",
      pack_size_required: true
    },
    nasal_spray: {
      name: "Nasal spray",
      strength_unit: "mcg",
      strength_required: true,
      pack_size_unit: "doses",
      pack_size_required: true
    },
    nutritional_liquid: {
      name: "Nutritional supplement (liquid)",
      strength_unit: "kcal/ml",
      strength_required: true,
      pack_size_unit: "ml",
      pack_size_required: true
    },
    nutritional_powder: {
      name: "Nutritional supplement (powder)",
      pack_size_unit: "g",
      pack_size_required: true
    },
    injectable: {
      name: "Injectable",
      strength_unit: "mg/ml",
      strength_required: true,
      pack_size_unit: "units",
      pack_size_required: true
    },
    leg_bag: {
      name: "Leg bag",
      volume_unit: "ml",
      volume_required: true,
      pack_size_unit: "bags",
      pack_size_required: true
    },
    night_bag: {
      name: "Night bag",
      volume_unit: "ml",
      volume_required: true,
      pack_size_unit: "bags",
      pack_size_required: true
    },
    catheter: {
      name: "Catheter",
      product_identifier_unit: "",
      product_identifier_required: true,
      channel_size_unit: "Fr",
      channel_size_required: true
    }
  }.freeze

  PERMITTED  = FORMS.keys.map(&:to_s)
  PROPERTIES = %w(strength pack_size volume product_identifier channel_size).freeze

  attr_reader :name, *PROPERTIES.map{ |prop| ["#{prop}_unit", "#{prop}_required"] }.flatten.map(&:to_sym)

  def initialize(
    name: nil,
    strength_unit: nil,
    strength_required: false,
    pack_size_unit: nil,
    pack_size_required: false,
    volume_unit: nil,
    volume_required: false,
    product_identifier_unit: nil,
    product_identifier_required: false,
    channel_size_unit: nil,
    channel_size_required: false
  )
    @name                        = name
    @strength_unit               = strength_unit
    @strength_required           = strength_required
    @pack_size_unit              = pack_size_unit
    @pack_size_required          = pack_size_required
    @volume_unit                 = volume_unit
    @volume_required             = volume_required
    @product_identifier_unit     = product_identifier_unit
    @product_identifier_required = product_identifier_required
    @channel_size_unit           = channel_size_unit
    @channel_size_required       = channel_size_required
  end

  def self.for(name)
    return unless PERMITTED.include?(name.to_s)
    Marketplace::ProductForm.new(FORMS.fetch(name.to_sym))
  end

  PERMITTED.each do |name|
    define_singleton_method(name) do
      Marketplace::ProductForm.for(name)
    end
  end

  PROPERTIES.each do |prop|
    define_method("#{prop}_required?") do
      !!self.send("#{prop}_required")
    end

    define_method("#{prop}_meaningful?") do
      !!self.send("#{prop}_unit")
    end
  end
end
