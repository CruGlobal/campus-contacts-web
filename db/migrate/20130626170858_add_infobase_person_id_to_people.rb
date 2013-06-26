class AddInfobasePersonIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :infobase_person_id, :integer
    add_index :people, :infobase_person_id
  end
end
