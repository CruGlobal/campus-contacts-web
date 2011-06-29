class Rejoicable < ActiveRecord::Base
  belongs_to :followup_comment, inverse_of: :rejoicables
  belongs_to :organization, inverse_of: :rejoicables
  belongs_to :created_by, class_name: "Person", foreign_key: "created_by_id", inverse_of: :rejoicables
  belongs_to :person
  OPTIONS = %w[spiritual_conversation prayed_to_receive gospel_presentation]
  
  def to_s
    I18n.t("ma.rejoicables.#{what}")
  end
end
