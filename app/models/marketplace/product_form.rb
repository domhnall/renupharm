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
      strength_unit: "mg",
      pack_size_unit: "ml"
    },
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
