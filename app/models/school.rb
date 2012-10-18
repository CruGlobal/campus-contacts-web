ActiveRecord::Base.inheritance_column = "activerecordtype"

class School < ActiveRecord::Base
  establish_connection :uscm
  self.table_name = "ministry_targetarea"
  self.primary_key = "targetAreaID"

# belongs_to :community

end
