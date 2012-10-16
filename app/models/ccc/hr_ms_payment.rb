class Ccc::HrMsPayment < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'paymentID'
  self.table_name = 'hr_ms_payment'
  
end
