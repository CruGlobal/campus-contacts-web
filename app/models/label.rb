class Label < ActiveRecord::Base
  attr_accessible :i18n, :name, :organization_id, :created_at, :updated_at
  # added :created_at and :updated_at for migration only

  has_many :people, through: :organizational_labels
  has_many :organizational_labels, dependent: :destroy
  belongs_to :organization

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, :if => Proc.new { |role| organization_id != 0 }
  validates :organization_id, presence: true

  scope :default, where(organization_id: 0) if Label.table_exists? # added for travis testing
end
