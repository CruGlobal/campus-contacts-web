class ChangeNameLengthOfPeople < ActiveRecord::Migration
  def change
    change_column :people, :first_name, :string, limit: 255
    change_column :people, :last_name, :string, limit: 255
  end
end
