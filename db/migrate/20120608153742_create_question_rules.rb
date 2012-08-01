class CreateQuestionRules < ActiveRecord::Migration
  def change
    create_table :mh_question_rules do |t|
      t.integer :survey_element_id
      t.integer :rule_id
      t.string :trigger_keywords
      t.string :extra_parameters

      t.timestamps
    end
  end
end
