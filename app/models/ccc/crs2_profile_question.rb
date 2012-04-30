class Ccc::Crs2ProfileQuestion < ActiveRecord::Base
  self.table_name = 'crs2_profile_question'
  belongs_to :crs2_registrant_type, class_name: 'Crs2RegistrantType', foreign_key: :registrant_type_id
end
