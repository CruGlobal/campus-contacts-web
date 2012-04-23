class Ccc::CrsPayment < ActiveRecord::Base
  self.primary_key = 'paymentID'
  self.table_name = 'crs_payment'
  
end
