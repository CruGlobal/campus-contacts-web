class Apis::V3::RolesController < Apis::V3::BaseController
  before_filter :get_role, only: [:show]
  before_filter :get_label, only: [:update, :destroy]

  def index
    order = params[:order] || 'name'

    roles = []
    roles << permission
    labels.each do |label|
      roles << label
    end

    list = roles

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show

    render json: {role: @role.attributes},
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    label = Label.new(params[:role])
    label.organization_id = current_organization.id

    if label.save
      render json: {role: label.attributes},
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: label.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @label.update_attributes(params[:role])
      render json: {role: @label.attributes},
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: role.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    @label.destroy
    render json: @label,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def permission
    current_person.permission_for_org_id(current_organization.id)
  end

  def labels
    current_person.labels_for_org_id(current_organization.id)
  end

  def get_role
    @role = Permission.where(id: params[:id]).try(:first)
    @role ||= Label.where(id: params[:id]).try(:first)
  end

  def get_label
    @label = Label.where(id: params[:id]).try(:first)
  end

  def available_includes
    [:email_addresses, :phone_numbers]
  end

end