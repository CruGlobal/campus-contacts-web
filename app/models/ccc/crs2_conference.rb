class Ccc::Crs2Conference < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_conference'
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

  def self.get_id_from_url(url)
    regex = /conferenceId=(\d*)/
    match = regex.match(url)
    if match
      match[1]
    end
  end

  def self.find_from_url_and_password(url, password)
    conference_id = Ccc::Crs2Conference.get_id_from_url(url)
    if conference_id
      Ccc::Crs2Conference.where(id: conference_id, admin_password: password).first
    end
  end
end

