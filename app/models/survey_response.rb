class SurveyResponse < ApplicationRecord
  WASTAGE_BUCKETS = %w(lt_200 200_500 500_1000 gt_1000).freeze

  belongs_to :sales_contact, class_name: 'Sales::Contact', optional: true
  before_save :serialize_full_response

  accepts_nested_attributes_for :sales_contact

  validates :question_1, :question_2, :question_3, :question_4, inclusion: { in: [true, false] }
  validates :question_5, inclusion: { in: WASTAGE_BUCKETS }
  validates :additional_notes, length: {maximum: 5000}, allow_blank: true

  def respondant_name
    sales_contact&.full_name
  end

  private

  def serialize_full_response
    self.full_response = self.as_json(except: [:id, :full_response, :created_at, :updated_at])
  end
end
