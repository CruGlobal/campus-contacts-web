class Ccc::Crs2Registration < ActiveRecord::Base
  set_table_name 'crs2_registration'
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'
  belongs_to :crs2_user, :class_name => 'Ccc::Crs2User', :foreign_key => :creator_id
  has_many :crs2_transactions, :class_name => 'Ccc::Crs2Transaction'

  def merge(other)
    # change old creator_id to new creator_id (crs2_user)
    # change old cancelled_by_id to new cancelled_by_id (crs2_user)
  end

end
