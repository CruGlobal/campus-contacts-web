class TargetArea < ActiveRecord::Base
  self.primary_key = 'targetAreaID'
  self.table_name = 'ministry_targetarea'
  set_inheritance_column 'not_in_use'
  
  has_many :activities
  has_many :organizations, through: :activities
end
