class CreateSurveyResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_responses do |t|
      t.references :sales_contact, foreign_key: true
      t.boolean :question_1
      t.boolean :question_2
      t.boolean :question_3
      t.boolean :question_4
      t.string :question_5
      t.text :additional_notes
      t.json :full_response
    end
  end
end
