ActiveRecord::Base.inheritance_column = "activerecordtype"

class School < ActiveRecord::Base
self.table_name = "ministry_targetarea"
self.primary_key = "targetAreaID"

# belongs_to :community

end
