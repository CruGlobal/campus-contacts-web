class OrganizationalLabelSerializer < ActiveModel::Serializer

  attributes :id, :person_id, :organization_id, :added_by_id, :label_id,
             :start_date, :created_at, :updated_at, :removed_date

  HAS_ONE = [:label]

  has_one *HAS_ONE

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      if HAS_ONE.include?(rel.to_sym)
        include!(rel.to_sym)
      end
    end if includes
  end

  def label
   object.label
  end
end

