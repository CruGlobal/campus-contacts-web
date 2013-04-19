class AddHiddenToMhElements < ActiveRecord::Migration
  def change
    add_column :elements, :hidden, :boolean, default: false, null: false
    add_column :elements, :related_question_sheet_id, :integer
  end
end
