class EmailResponse < ActiveRecord::Base
  enum response_type: [:bounce, :complaint]

  validates_presence_of :email

  attr_accessible :email, :response_type, :extra_info
end
