class CreateQuestionLeaders < ActiveRecord::Migration
  def change
    create_table :question_leaders do |t|
      t.integer :person_id
      t.integer :element_id

      t.timestamps
    end
  end
end
