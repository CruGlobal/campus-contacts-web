class Rejoicable < ActiveRecord::Base
  belongs_to :followup_comment, inverse_of: :rejoicables
  belongs_to :organization, inverse_of: :rejoicables
  belongs_to :created_by, class_name: "Person", foreign_key: "created_by_id", inverse_of: :rejoicables
  belongs_to :person
  OPTIONS = %w[spiritual_conversation prayed_to_receive gospel_presentation]
  
  before_create :force_comment_attributes
  
  default_scope where(:deleted_at => nil)
  
  def destroy
    run_callbacks :destroy do
      self.update_attribute(:deleted_at, DateTime.now)
    end
  end
  
  def delete
    run_callbacks :delete do
      self.update_attribute(:deleted_at, DateTime.now)
    end
  end
  
  def to_s
    I18n.t("rejoicables.#{what}")
  end
  
  private
  
  def force_comment_attributes
    if followup_comment
      self.followup_comment_id = followup_comment.id
      self.person_id = followup_comment.contact_id
      self.created_by_id = followup_comment.commenter_id
      self.organization_id = followup_comment.organization_id
    end
  end
  
end
