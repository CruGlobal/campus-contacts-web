class EmailAddress < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { person_id: :person_id }

  belongs_to :person, inverse_of: :email_addresses, touch: true
  validates_presence_of :email, on: :create, message: "can't be blank"
  validates_format_of :email, with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  before_validation :set_primary, on: :create
  after_commit :ensure_only_one_primary
  after_destroy :set_new_primary
  #validates_uniqueness_of :email, on: :create, message: "already taken"
  #validates_uniqueness_of :email, on: :update, message: "already taken"
  strip_attributes :only => :email

  def to_s
    email
  end

  def merge(other)
    EmailAddress.transaction do
      if updated_at && other.primary? && other.updated_at && other.updated_at > updated_at
        person.email_addresses.collect {|e| e.update_attribute(:primary, false)}
        new_primary = person.email_addresses.detect {|e| e.email == other.email}
        new_primary.update_attribute(:primary, true) if new_primary
      end
      begin
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.reload
        other.destroy
      rescue ActiveRecord::RecordNotFound
        # ???
      end
    end
  end

  def is_unique?
    EmailAddress.where(email: email).blank?
  end

  protected

  def set_primary
    if person
      if !person.primary_email_address.frozen? && person.primary_email_address && person.primary_email_address.valid?
        self.primary = false
      else
        person.primary_email_address.try(:destroy)
        self.primary = true
      end
    else
      self.primary = true
    end
    true
  end

  def ensure_only_one_primary
    remove_duplicate_email_from_person if person.email_addresses.length > 1

    primary_emails = person.email_addresses.where(primary: true)
    if primary_emails.blank?
      person.email_addresses.last.update_column(:primary, true)
    elsif primary_emails.length > 1
      primary_emails[0..-2].map {|e| e.update_column(:primary, false)}
    end
  end

  def remove_duplicate_email_from_person
    person.email_addresses.order("id DESC").group(:email).uniq.each do |e|
      person.email_addresses.where("person_id = ? AND id <> ? AND email = ?", person.id, e.id, e.to_s).try(:destroy_all)
    end
  end

  def set_new_primary
    if self.primary?
      if person && person.email_addresses.present?
        person.email_addresses.first.update_attribute(:primary, true)
      end
    end
    true
  end

end
