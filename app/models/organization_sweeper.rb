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
      # If the parent of this org shows sub-orgs, we need to clear cache
      begin
        if object.ancestry.present? && object.parent.show_sub_orgs?
          OrganizationalRole.where(organization_id: object.parent.id).includes(:person).map { |role| expire_cache_for_role(role) }
        end
      rescue ActiveRecord::RecordNotFound
      end
    when OrganizationalRole
      expire_cache_for_role(object)
    end
  end

  def expire_cache_for_role(role)
    if role.person
      role.person.clear_org_cache
      expire_fragment("org_nav/#{role.person.id}")
    end
  end
end
