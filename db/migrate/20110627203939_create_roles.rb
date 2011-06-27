class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :organization_id
      t.string :name
      t.string :i18n

      t.timestamps
    end
  end
end
