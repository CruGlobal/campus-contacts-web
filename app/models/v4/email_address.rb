module V4
  class EmailAddress < ActiveRecord::Base
    has_paper_trail on: [:destroy],
                    meta: { person_id: :person_id }

    belongs_to :person, inverse_of: :email_addresses, touch: true
    validates_presence_of :email, on: :create, message: "can't be blank"
    validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
    after_commit :ensure_only_one_primary
    strip_attributes only: :email

    def to_s
      email
    end

    def ensure_only_one_primary
      remove_duplicate_email_from_person if person.email_addresses.length > 1
      return unless person.email_addresses.any?

      primary_emails = person.email_addresses.where(primary: true)
      if primary_emails.blank?
        person.email_addresses.last.update_column(:primary, true)
      elsif primary_emails.length > 1
        primary_emails[0..-2].map { |e| e.update_column(:primary, false) }
      end
    end

    def remove_duplicate_email_from_person
      person.email_addresses.order('id DESC').group(:email).uniq.each do |e|
        person.email_addresses.where(person_id: person.id, email: e.email.downcase).where.not(id: e.id).try(:destroy_all)
      end
    end
  end
end
