class Ccc::Crs2UserRole < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_user_role'
  self.inheritance_column = 'fake_column'
  belongs_to :crs2_conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :user_id

end
