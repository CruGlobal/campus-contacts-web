class Ccc::MinistryLocallevel < ActiveRecord::Base
  set_primary_key :teamID
  set_table_name 'ministry_locallevel'
  has_many :ministry_missional_team_members, :class_name => 'Ccc::MinistryMissionalTeamMember'
end
