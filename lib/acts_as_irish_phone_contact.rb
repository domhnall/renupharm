# Numbers are stored without the +353 prefix
# A number of the format "+353 1234567" will appear unaltered by a getter-setter invocation
module ActsAsIrishPhoneContact
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_irish_phone_contact(column_names = [:telephone])
      column_names = Array(column_names)
      validates *column_names, length: { minimum: 11, maximum: 16 }, allow_blank: true

      column_names.each do |column_name|
        define_method "#{column_name}=".to_sym do |value|
          super(value && value.gsub(/[^\d]/,"").gsub(/\A0+/,"").gsub(/\A353/,"").gsub(/\A0+/,""))
        end

        define_method "#{column_name}".to_sym do
          return self[column_name] if self[column_name].blank?
          "+353 #{self[column_name]}"
        end
      end
    end
  end
end
