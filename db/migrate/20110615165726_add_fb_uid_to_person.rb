class AddFbUidToPerson < ActiveRecord::Migration
  def self.up
    change_table Person.table_name do |t|
      t.column :fb_uid, 'BIGINT UNSIGNED'
    end
    add_index Person.table_name, :fb_uid
  end
  
  def self.down
    remove_column Person.table_name, :fb_uid
  end
end
