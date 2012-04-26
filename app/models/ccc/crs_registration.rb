class Ccc::CrsRegistration < ActiveRecord::Base
  #belongs_to :person
  self.primary_key = 'registrationID'
  self.table_name = 'crs_registration'
 
end
