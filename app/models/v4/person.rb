# encoding: utf-8
module V4
  class Person < ActiveRecord::Base
    belongs_to :user

    PERMITTED_ATTRIBUTES = [
      :first_name, :last_name, :middle_name, :gender, :campus,
      {
        addresses_attributes: [
          :address_type, :address1, :address2, :address3, :address4, :city, :state, :zip,
          :dorm, :room, :country, :start_date, :end_date
        ]
      }
    ]
  end
end
