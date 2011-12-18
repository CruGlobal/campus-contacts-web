class Ccc::Crs2Conference < ActiveRecord::Base
  set_table_name 'crs2_conference'
  has_many :crs2_additional_info_items, class_name: 'Ccc::Crs2AdditionalInfoItem'
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :creator_id
  belongs_to :crs2_url_base, class_name: 'Ccc::Crs2UrlBase', foreign_key: :url_base_id
  has_many :crs2_custom_stylesheets, class_name: 'Ccc::Crs2CustomStylesheet'
  has_many :crs2_expenses, class_name: 'Ccc::Crs2Expense'
  has_many :crs2_module_usages, class_name: 'Ccc::Crs2ModuleUsage'
  has_many :crs2_questions, class_name: 'Ccc::Crs2Question'
  has_many :crs2_registrant_types, class_name: 'Ccc::Crs2RegistrantType'
  has_many :crs2_transactions, class_name: 'Ccc::Crs2Transaction'
  has_many :crs2_user_roles, class_name: 'Ccc::Crs2UserRole'

  def to_s
    name
  end
end
