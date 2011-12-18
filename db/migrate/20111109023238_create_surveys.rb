class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :mh_surveys do |t|
      t.string :title
      t.belongs_to :organization

      t.timestamps
    end
    add_index :mh_surveys, :organization_id
  end
end
