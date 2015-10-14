# encoding: utf-8
module V4
  class Person < ActiveRecord::Base
    has_paper_trail on: [:destroy],
                    meta: { person_id: :id }

    belongs_to :user

    has_many :email_addresses, dependent: :destroy

    PERMITTED_ATTRIBUTES = [
      :first_name, :last_name, :middle_name, :gender, :campus,
      {
        addresses_attributes: [
          :address_type, :address1, :address2, :address3, :address4, :city, :state, :zip,
          :dorm, :room, :country, :start_date, :end_date
        ]
      }
    ]

    def email
      primary_email_address.try(:email).try(:to_s)
    end

    def primary_email_address
      @primary ||= email_addresses.find_by(primary: true)
      @primary ||= email_addresses.last
    end

    def email=(val)
      return if val.blank?
      e = email_addresses.find_or_initialize_by(email: val)
      if !e.id
        e.primary = true
        e.save
      elsif !e.primary == true
        e.update_attribute(:primary, true)
      end
    end

    def create_user!
      reload
      return unless email && user.blank?
      if user = User.find_by(username: email)
        if user.person
          user.person.merge(self)
          return user.person
        else
          self.user = user
        end
      else
        update_attribute :user, V4::User.create!(username: email)
      end
    end
  end
end
