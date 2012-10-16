class Ccc::HrReview360Reviewsessionlight < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'ReviewSessionLightID'
  self.table_name = 'hr_review360_reviewsessionlight'
  
end
