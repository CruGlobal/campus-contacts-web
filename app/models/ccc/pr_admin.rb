class Ccc::PrAdmin < ActiveRecord::Base
  establish_connection :uscm

  #belongs_to :person
  self.table_name = "pr_admins"

end
