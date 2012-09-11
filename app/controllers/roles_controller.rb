class RolesController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize
  before_filter :set_role, :only => [:new, :edit, :update, :destroy]
 
  def index
    @organizational_roles = Role.where(organization_id: current_organization.id)
    @system_roles = Role.default
  end
  
  def new
  end
  
  def edit
  end

  def create
    Role.transaction do
      @role = Role.new(params[:role])
      @role.organization_id = current_organization.id
      if @role.save
        redirect_to roles_path
      else
        render :new
      end
    end
  end
  
  def create_now
    @status = false
    if params[:name].present?
      if Role.where("organization_id IN (?) AND LOWER(name) = ?", [current_organization.id,0], params[:name].downcase).present?
        @msg_alert = t('contacts.index.add_label_exists')
      else
        @new_role = Role.create(organization_id: current_organization.id, name: params[:name]) if params[:name].present?
        if @new_role.present?
          @status = true
          @msg_alert = t('contacts.index.add_label_success')
        else
          @msg_alert = t('contacts.index.add_label_failed')
        end
      end
    else
      @msg_alert = t('contacts.index.add_label_empty')
    end
  end

  def update
    if @role.update_attributes(params[:role])
      redirect_to roles_path
    else 
      render :edit
    end
  end

  def destroy
    @role.destroy
    redirect_to roles_path
  end

 protected
  def authorize
    authorize! :manage_roles, current_organization
  end

  def set_role
    @role = case action_name 
    when 'new' then Role.new
    else Role.find(params[:id]) 
    end 
  end
end
