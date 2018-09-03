class SurveyResponse < ApplicationRecord
  WASTAGE_BUCKETS = %w(lt_200 200_500 500_1000 gt_1000).freeze

  belongs_to :sales_contact, class_name: 'Sales::Contact'
  before_save :serialize_full_response

  accepts_nested_attributes_for :sales_contact

  validates :question_1, :question_2, :question_3, :question_4, :question_5, presence: true
  validates :question_5, inclusion: { in: WASTAGE_BUCKETS }

  private

  def serialize_full_response
    self.full_response = self.as_json(except: [:id, :full_response])
  end
end
