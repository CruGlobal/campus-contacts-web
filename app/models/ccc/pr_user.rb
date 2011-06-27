class PrUser < ActiveRecord::Base
  belongs_to :user, foreign_key: :ssm_id
  belongs_to :person

end
