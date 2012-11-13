class Ccc::HrSiUser < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'siUserID'
  
end
