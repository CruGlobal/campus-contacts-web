class AddAdvancedFieldsToQuestions < ActiveRecord::Migration
  def change
    add_column :mh_elements, :trigger_words, :string
    add_column :mh_elements, :notify_via, :string
  end
end
