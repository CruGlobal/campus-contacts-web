class AddDatesToQuestionnaireTables < ActiveRecord::Migration
  def change
    add_column :mh_answer_sheets, :updated_at, :datetime
    add_column :mh_answers, :created_at, :datetime
    add_column :mh_answers, :updated_at, :datetime
  end
end