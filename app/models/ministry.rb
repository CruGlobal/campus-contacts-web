ActiveRecord::Base.inheritance_column = "activerecordtype"

class Ministry < ActiveRecord::Base
set_table_name "sn_ministries"
end
