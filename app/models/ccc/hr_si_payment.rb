class Ccc::HrSiPayment < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'paymentID'
  self.table_name = 'hr_si_payment'
  
end
