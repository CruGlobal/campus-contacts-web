class CreateSuperAdmins < ActiveRecord::Migration
  def change
    create_table :super_admins do |t|
      t.belongs_to :user
      t.string :site

      t.timestamps
    end
    add_index :super_admins, :user_id
  end
end
