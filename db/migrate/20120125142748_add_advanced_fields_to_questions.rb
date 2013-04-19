class AddAdvancedFieldsToQuestions < ActiveRecord::Migration
  def change
    add_column :elements, :trigger_words, :string
    add_column :elements, :notify_via, :string
  end
end
