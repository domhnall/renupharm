module ActsAsIrishPhoneContact
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_irish_phone_contact(column_names = [:telephone])
      column_names = Array(column_names)
      validates *column_names, length: { minimum: 7, maximum: 11 }, allow_blank: true

      column_names.each do |column_name|
        define_method "#{column_name}=".to_sym do |value|
          super(value && value.gsub(/[^\d]/,'').sub(/\A([^0])/,'0\1'))
        end
      end
    end
  end
end
