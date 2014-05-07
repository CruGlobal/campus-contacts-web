class AddCruStatusIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :cru_status_id, :integer, after: 'gender'
    add_column :people, :student_status, :string, after: 'cru_status_id'
  end
end
