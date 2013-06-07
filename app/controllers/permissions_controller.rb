class PermissionsController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize
  before_filter :set_permission, :only => [:new, :edit, :update, :destroy]
 
  def index
    @organizational_permissions = current_organization.non_default_permissions
    @system_permissions = current_organization.default_permissions
  end

 protected
  def authorize
    authorize! :manage_permissions, current_organization
  end
end
