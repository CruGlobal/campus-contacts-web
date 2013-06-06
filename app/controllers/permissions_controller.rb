class PermissionsController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize
  before_filter :set_permission, :only => [:new, :edit, :update, :destroy]
 
  def index
    @organizational_permissions = current_organization.non_default_permissions
    @system_permissions = current_organization.default_permissions
  end
  
  def new
  end
  
  def edit
  end

  def create
    Permission.transaction do
      @permission = Permission.new(params[:permission])
      @permission.organization_id = current_organization.id
      if @permission.save
        redirect_to permissions_path
      else
        render :new
      end
    end
  end
  
  def create_now
    @status = false
    if params[:name].present?
      if Permission.where("organization_id IN (?) AND LOWER(name) = ?", [current_organization.id,0], params[:name].downcase).present?
        @msg_alert = t('contacts.index.add_label_exists')
      else
        @new_permission = Permission.create(organization_id: current_organization.id, name: params[:name]) if params[:name].present?
        if @new_permission.present?
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
    if @permission.update_attributes(params[:permission])
      redirect_to permissions_path
    else 
      render :edit
    end
  end

  def destroy
    @permission.destroy
    redirect_to permissions_path
  end

 protected
  def authorize
    authorize! :manage_permissions, current_organization
  end

  def set_permission
    @permission = case action_name 
    when 'new' then Permission.new
    else Permission.find(params[:id]) 
    end 
  end
end
