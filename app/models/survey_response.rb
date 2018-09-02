class SurveyResponse < ApplicationRecord
  belongs_to :sales_contact, class_name: 'Sales::Contact'
  before_save :serialize_full_response

  accepts_nested_attributes_for :sales_contact

  private

  def serialize_full_response
    self.full_response = self.as_json(except: [:id, :full_response])
  end
end
