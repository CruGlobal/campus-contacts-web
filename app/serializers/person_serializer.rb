class PersonSerializer < ActiveModel::Serializer
  HAS_MANY = [:phone_numbers, :email_addresses, :person_transfers, :contact_assignments,
             :followup_comments, :organizational_roles, :rejoicables, :answer_sheets]

  HAS_ONE = [:user]

  INCLUDES = HAS_MANY + HAS_ONE

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date,
             :date_became_christian, :graduation_date, :user_id, :fb_uid, :created_at, :updated_at

  has_many *HAS_MANY
  has_one *HAS_ONE

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      if INCLUDES.include?(rel.to_sym)
        include!(rel.to_sym)
      end
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

  [:phone_numbers, :email_addresses, :person_transfers, :user, :answer_sheets].each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end


end

