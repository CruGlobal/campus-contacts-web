class Ccc::HrReview360Reviewsession < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'ReviewSessionID'
  self.table_name = 'hr_review360_reviewsession'
  
end
