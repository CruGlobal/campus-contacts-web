class CreateCustomElementLabels < ActiveRecord::Migration
  def change
    create_table :custom_element_labels do |t|
      t.integer :survey_id
      t.integer :question_id
      t.text :label

      t.timestamps
    end
  end
end
