class CreateRules < ActiveRecord::Migration
  def change
    create_table :mh_rules do |t|
      t.string :name
      t.string :description
      t.string :action_method

      t.timestamps
    end
  end
end
