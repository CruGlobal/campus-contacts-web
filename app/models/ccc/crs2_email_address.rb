class Ccc::Crs2EmailAddress < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_email_addresses'
  belongs_to :crs2_person, class_name: 'Ccc::Crs2Person', foreign_key: :person_id, inverse_of: :email_addresses


end

