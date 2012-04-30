class Ccc::MinistryMissionalTeamMember < ActiveRecord::Base
  self.table_name = 'ministry_missional_team_member'
  belongs_to :ministry_locallevel, class_name: 'Ccc::MinistryLocallevel', foreign_key: :teamID
  belongs_to :ministry_person, class_name: 'Person', foreign_key: :personID

end
