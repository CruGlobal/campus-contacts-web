class Ccc::CrsRegistration < ActiveRecord::Base
  #belongs_to :person
  set_primary_key :registrationID
  set_table_name 'crs_registration'
 
end
