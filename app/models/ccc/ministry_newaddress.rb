class Ccc::MinistryNewaddress < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'id'
  self.table_name = 'ministry_newaddress'
  belongs_to :ministry_person, class_name: 'Person', foreign_key: :person_id
end