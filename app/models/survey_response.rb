class SurveyResponse < ApplicationRecord
  before_save :serialize_full_response

  private

  def serialize_full_response
    self.full_response = self.as_json(except: [:id, :full_response])
  end
end
