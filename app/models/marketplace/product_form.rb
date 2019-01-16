class Marketplace::ProductForm
  attr_reader :name, :strength_unit, :pack_size_unit

  FORMS = {
    hard_capsules: {
      name: "Hard capsules",
      strength_unit: "mg",
      pack_size_unit: "caps"
    },
    soft_capsules: {
      name: "Soft capsules",
      strength_unit: "mg",
      pack_size_unit: "caps"
    },
    cream: {
      name: "Cream",
      strength_unit: "%",
      pack_size_unit: "g"
    },
    pessaries: {
      name: "Pressaries",
      strength_unit: "mg",
      pack_size_unit: "caps"
    },
    liquid: {
      name: "Liquid",
      strength_unit: "",
      pack_size_unit: "ml"
    },
    drops: {
      name: "Drops",
      strength_unit: "%",
      pack_size_unit: "ml"
    },
    sdu: {
      name: "Single-dosage unit",
      strength_unit: "%",
      pack_size_unit: "dose"
    },
    flexpen: {
      name: "Flexpen",
      strength_unit: "mg",
      pack_size_unit: "pens"
    }
  }.freeze

  PERMITTED = FORMS.keys.map(&:to_s)

  def initialize(name: nil, strength_unit: nil, pack_size_unit: nil)
    @name = name
    @strength_unit = strength_unit
    @pack_size_unit = pack_size_unit
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
end
