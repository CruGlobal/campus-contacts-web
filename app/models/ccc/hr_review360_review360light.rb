class Ccc::HrReview360Review360light < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'Review360LightID'
  self.table_name = 'hr_review360_review360light'
  
end
