class Ccc::PrUser < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :user, foreign_key: :ssm_id
  belongs_to :person

end
