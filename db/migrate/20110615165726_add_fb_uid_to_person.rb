class AddFbUidToPerson < ActiveRecord::Migration
  def self.up
    change_table Person.table_name do |t|
      t.column :fb_uid, 'BIGINT UNSIGNED'
    end
    add_index Person.table_name, :fb_uid
    Authentication.where(:provider => 'facebook').each do |a|
      if a.user.try(:person)
        a.user.person.update_attribute(:fb_uid, a.uid)
      end
    end
  end
  
  def self.down
    remove_column Person.table_name, :fb_uid
  end
end
