class PermissionsController < ApplicationController
  before_action :ensure_current_org
  before_action :authorize
  before_action :set_permission, only: [:new, :edit, :update, :destroy]

  def index
    @organizational_permissions = current_organization.non_default_permissions
    @system_permissions = current_organization.default_permissions
  end

  protected

  def authorize
    authorize! :manage_permissions, current_organization
  end
end
