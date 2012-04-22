class ImportsController < ApplicationController

  before_filter :get_import, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @import = Import.new
  end

  def create
    @import = current_user.imports.new(params[:import])
    import.organization = current_organization
    if @import.save
      redirect_to edit_import_path(@import)
    else
      render :new
    end
  end

  def edit
  end

  def update
    @import.update_attributes(params[:import])
    errors = @import.check_for_errors
    if errors.blank?
      @import.import
      redirect_to @import
    else
      flash.now[:error] = errors.join('<br />').html_safe
      render :edit
    end
  end

  def destroy
    @import.destroy
    redirect_to contacts_path
  end

  protected

  def get_import
    @import = current_user.imports.where(organization_id: current_organization.id).find(params[:id])
  end
end
