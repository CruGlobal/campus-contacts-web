class Ccc::MinistryLocallevel < ActiveRecord::Base
  self.primary_key = 'teamID'
  self.table_name = 'ministry_locallevel'
  has_many :ministry_missional_team_members, class_name: 'Ccc::MinistryMissionalTeamMember'
end
