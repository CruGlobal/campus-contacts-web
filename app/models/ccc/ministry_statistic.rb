class Ccc::MinistryStatistic < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'StatisticID'
  self.table_name = 'ministry_statistic'
  
end
