class OrganizationSweeper < ActionController::Caching::Sweeper
  observe Organization, OrganizationalRole

  def after_create(object)
    expire_cache_for(object)
  end
 
  def after_update(object)
    expire_cache_for(object)
  end
 
  def after_destroy(object)
    expire_cache_for(object)
  end
 
  private
  def expire_cache_for(object)
    case object
    when Organization
      Person.where('org_ids_cache like :org OR org_ids_cache like :parent', org: "%\"#{object.id}\"%", parent: "%\"#{object.parent_id}\"%").map {|p| expire_cache_for_person(p) }
      # If the parent of this org shows sub-orgs, we need to clear cache
      #begin
        #if object.ancestry.present? && object.parent.show_sub_orgs?
          #raise OrganizationalRole.where(organization_id: object.parent.id).all.inspect
          #OrganizationalRole.where(organization_id: object.parent.id).includes(:person).map { |role| expire_cache_for_role(role) }
        #end
        ##OrganizationalRole.where(organization_id: object.id).includes(:person).map { |role| expire_cache_for_role(role) }
      #rescue ActiveRecord::RecordNotFound
      #end
    when OrganizationalRole
      expire_cache_for_person(object.person)
    end
  end

  def expire_cache_for_person(person)
    if person
      person.clear_org_cache
      expire_fragment("org_nav/#{person.id}")
    end
  end
end
