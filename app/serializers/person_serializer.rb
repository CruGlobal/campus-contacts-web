class PersonSerializer < ActiveModel::Serializer

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date,
             :date_became_christian, :graduation_date, :user_id, :fb_uid, :updated_at, :created_at

  has_many :phone_numbers, :email_addresses

  def include_associations!
    include! :phone_numbers if scope.include?('phone_numbers')
    include! :email_addresses if scope.include?('email_addresses')
  end

end

