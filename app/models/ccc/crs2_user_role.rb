class Ccc::Crs2UserRole < ActiveRecord::Base
  set_table_name 'crs2_user_role'
  belongs_to :crs2_conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :user_id

end
