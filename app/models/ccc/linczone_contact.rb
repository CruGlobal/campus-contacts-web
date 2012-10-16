class Ccc::LinczoneContact < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'ContactID'
  
end
