class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.belongs_to :organization
      t.string :name

      t.timestamps
    end
    add_index :teams, :organization_id
  end
end