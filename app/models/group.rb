class Group < ActiveRecord::Base
  set_table_name 'mh_groups'
  validates_presence_of :name, :location, :meets
end
