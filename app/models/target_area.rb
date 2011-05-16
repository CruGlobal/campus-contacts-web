class TargetArea < ActiveRecord::Base
  set_primary_key :targetAreaID
  set_table_name 'ministry_targetarea'
  set_inheritance_column 'not_in_use'
  
  has_many :activities
  has_many :organizations, :through => :activities
end
