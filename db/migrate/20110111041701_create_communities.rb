class CreateCommunities < ActiveRecord::Migration
  def self.up
    create_table :communities do |t|
      t.string :name
      t.string :website
      t.string :fbpage

      t.timestamps
    end
  end

  def self.down
    drop_table :communities
  end
end
