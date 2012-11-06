class Ccc::HrReview360Review360 < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'Review360ID'
  self.table_name = 'hr_review360_review360'
  
end
