class Ccc::MinistryStrategy < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'strategyID'
  self.table_name = 'ministry_strategy'
  
end
