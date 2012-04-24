class ImportsController < ApplicationController
  before_filter :get_import, only: [:show, :edit, :update, :destroy]
  before_filter :init_org, only: [:index, :show, :edit, :update, :new]
  rescue_from Import::NilColumnHeader, with: :nil_column_header

  def index
  end

  def show
  end

  def new
    @import = Import.new
  end

  def create
    @import = current_user.imports.new(params[:import])
    @import.organization = current_organization
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

  def download_sample_contacts_csv
    csv_string = CSV.generate do |csv|
      c = 0
      CSV.foreach(Rails.root.to_s + "/public/files/sample_contacts.csv") do |row|
        c = c + 1
        csv << row
      end
    end
    send_data csv_string, :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=sample_contacts.csv"
  end

  def nil_column_header
    init_org
    flash.now[:error] = "Nil Header"
    render :new
  end

  protected

  def get_import
    @import = current_user.imports.where(organization_id: current_organization.id).find(params[:id])
  end

  def init_org
    @organization = current_organization
    authorize! :manage, @organization
  end
end
