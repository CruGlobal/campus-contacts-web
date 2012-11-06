class Ccc::Authentication < ActiveRecord::Base
  establish_connection :uscm

  belongs_to :user, class_name: 'Ccc::SimplesecuritymanagerUser', foreign_key: 'user_id'
  
end
