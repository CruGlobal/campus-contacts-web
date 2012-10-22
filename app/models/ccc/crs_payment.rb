class Ccc::CrsPayment < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'paymentID'
  self.table_name = 'crs_payment'
  
end
