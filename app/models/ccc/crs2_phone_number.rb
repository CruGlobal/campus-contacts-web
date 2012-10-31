class Ccc::Crs2PhoneNumber < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_phone_numbers'
  belongs_to :crs2_person, class_name: 'Ccc::Crs2Person', foreign_key: :person_id, inverse_of: :phone_numbers


end

