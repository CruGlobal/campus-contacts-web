class AddDatesToQuestionnaireTables < ActiveRecord::Migration
  def change
    add_column :answer_sheets, :updated_at, :datetime
    add_column :answers, :created_at, :datetime
    add_column :answers, :updated_at, :datetime
  end
end