class Signature < ActiveRecord::Base
  SIGNATURE_CODE_OF_CONDUCT = "code_of_conduct"
  SIGNATURE_STATEMENT_OF_FAITH = "statement_of_faith"
  SIGNATURE_STATUS_ACCEPTED = "accepted"
  SIGNATURE_STATUS_DECLINED = "declined"

  SIGNATURES = [SIGNATURE_CODE_OF_CONDUCT, SIGNATURE_STATEMENT_OF_FAITH]
  SIGNATURE_STATUSES = [SIGNATURE_STATUS_ACCEPTED, SIGNATURE_STATUS_DECLINED]
  attr_accessible :organization_id, :kind, :status
  belongs_to :person
  belongs_to :organization

  scope :filter, -> (search_name){
    data = all.joins("LEFT JOIN people ON people.id = signatures.person_id")
      .joins("LEFT JOIN organizations ON organizations.id = signatures.organization_id")
    if search_name.present?
      data = Person.search_by_name(search_name, nil, data)
    end
    data
  }

  scope :sort, -> (sort_query){
    return all unless sort_query.present?

    sort_query = sort_query[:s]
    if sort_query.present?
      data = joins("LEFT JOIN people ON people.id = signatures.person_id")
        .joins("LEFT JOIN organizations ON organizations.id = signatures.organization_id")
      if sort_query.include?('first_name')
        return data.order("people.first_name #{sort_query.include?('asc') ? "asc" : "desc"}")
      elsif sort_query.include?('last_name')
        return data.order("people.last_name #{sort_query.include?('asc') ? "asc" : "desc"}")
      elsif sort_query.include?('organization')
        return data.order("organizations.name #{sort_query.include?('asc') ? "asc" : "desc"}")
      elsif sort_query.include?('kind')
        return data.order("signatures.kind #{sort_query.include?('asc') ? "asc" : "desc"}")
      elsif sort_query.include?('status')
        return data.order("signatures.status #{sort_query.include?('asc') ? "asc" : "desc"}")
      elsif sort_query.include?('created_at')
        return data.order("signatures.created_at #{sort_query.include?('asc') ? "asc" : "desc"}")
      else
        return data.order("signatures.created_at asc")
      end
    else
      return data.order("signatures.created_at asc")
    end
  }
end
