class AddTimestampsToSurveyResponses < ActiveRecord::Migration[5.2]
  def change
    # Add new columns and allow NULL
    add_timestamps :survey_responses, null: true

    # Default all existing columns
    ActiveRecord::Base::connection.execute("UPDATE survey_responses SET updated_at = NOW(), created_at = NOW()")

    # Update columns to be NOT NULL
    change_column_null :survey_responses, :created_at, false
    change_column_null :survey_responses, :updated_at, false
  end
end
