class Ccc::Crs2Conference < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_conference'
  has_many :additional_info_items, class_name: 'Ccc::Crs2AdditionalInfoItem', foreign_key: :conference_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :creator_id
  belongs_to :url_base, class_name: 'Ccc::Crs2UrlBase', foreign_key: :url_base_id
  has_many :custom_stylesheets, class_name: 'Ccc::Crs2CustomStylesheet', foreign_key: :conference_id
  has_many :expenses, class_name: 'Ccc::Crs2Expense', foreign_key: :conference_id
  has_many :module_usages, class_name: 'Ccc::Crs2ModuleUsage', foreign_key: :conference_id
  has_many :questions, class_name: 'Ccc::Crs2Question', foreign_key: :conference_id
  has_many :registrant_types, class_name: 'Ccc::Crs2RegistrantType', foreign_key: :conference_id
  has_many :transactions, class_name: 'Ccc::Crs2Transaction', foreign_key: :conference_id
  has_many :user_roles, class_name: 'Ccc::Crs2UserRole', foreign_key: :conference_id

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

