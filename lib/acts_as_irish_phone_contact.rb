# IE phone numbers
# Numbers are stored without the +353 prefix
# A number of the format "+353 1234567" will appear unaltered by a getter-setter invocation
#
# UK phone numbers
# Numbers are stored without the +44 prefix
# A number of the format "+44 7746926569" will appear unaltered by a getter-setter invocation
#
# The including class needs to offer an override to the #country_code method.
# This should return IE or UK depending if the contact is an IE or UK number.
# (I know UK is not the ISO country code for the UK, it is in fact GB, but that is an aberration)
# In the event this method is not overridden the default behaviour is to be treated as an IE number.
#
module ActsAsIrishPhoneContact
  extend ActiveSupport::Concern

  IE_COUNTRY_CODE = "IE".freeze
  UK_COUNTRY_CODE = "UK".freeze

  def country_code
    "IE"
  end

  def is_ie?
    country_code==IE_COUNTRY_CODE
  end

  def is_uk?
    country_code==UK_COUNTRY_CODE
  end

  module ClassMethods
    def acts_as_irish_phone_contact(column_names = [:telephone])
      column_names = Array(column_names)
      validates *column_names, length: { minimum: 11, maximum: 16 }, allow_blank: true

      column_names.each do |column_name|
        define_method "#{column_name}=".to_sym do |value|
          if is_uk?
            super(value && value.gsub(/[^\d]/,"").gsub(/\A0+/,"").gsub(/\A44/,"").gsub(/\A0+/,""))
          else
            super(value && value.gsub(/[^\d]/,"").gsub(/\A0+/,"").gsub(/\A353/,"").gsub(/\A0+/,""))
          end
        end

        define_method "#{column_name}".to_sym do
          return self[column_name] if self[column_name].blank?
          [ is_uk? ? "+44" : "+353", self[column_name] ].join(" ")
        end
      end
    end
  end
end
