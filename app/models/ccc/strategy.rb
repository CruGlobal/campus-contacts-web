class Ccc::Strategy < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'ministry_strategy'
  self.primary_key = 'strategyID'
end
