class FixSavedContactSearchesFullPathStringLength < ActiveRecord::Migration
  def change
    change_column :saved_contact_searches, :full_path, :string, :limit => 200
  end
end
