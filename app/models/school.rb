ActiveRecord::Base.inheritance_column = "activerecordtype"

class School < ActiveRecord::Base
set_table_name "ministry_targetarea"
set_primary_key "targetAreaID"

# belongs_to :community

end
