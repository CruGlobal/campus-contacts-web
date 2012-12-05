class PersonSerializer < ActiveModel::Serializer
  INCLUDES = [:phone_numbers, :email_addresses, :person_transfers, :contact_assignments,
           :followup_comments, :organizational_roles, :rejoicables]

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date,
             :date_became_christian, :graduation_date, :user_id, :fb_uid, :updated_at, :created_at

  has_many *INCLUDES

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      include!(rel.to_sym) if INCLUDES.include?(rel.to_sym)
    end if includes
  end

  def contact_assignments
    add_since(organization_filter(:contact_assignments))
  end

  def followup_comments
    add_since(organization_filter(:followup_comments))
  end

  def organizational_roles
    add_since(organization_filter(:organizational_roles))
  end

  def rejoicables
    add_since(organization_filter(:rejoicables))
  end

  [:phone_numbers, :email_addresses, :person_transfers].each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end


end

