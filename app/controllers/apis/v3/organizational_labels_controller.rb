class Apis::V3::OrganizationalLabelsController < Apis::V3::BaseController
  before_filter :ensure_filters, only: [:bulk, :bulk_create, :bulk_destroy]
  before_filter :get_org_label, only: [:show, :update, :destroy]

  def index
    list = add_includes_and_order(organizational_labels)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @organizational_label,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    org_label = OrganizationalLabel.new(params[:organizational_label])
    org_label.organization_id = current_organization.id
    org_label.added_by_id = current_person.id

    if org_label.save
      render json: org_label,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: org_label.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @organizational_label.organization_id != 0
      if @organizational_label.update_attributes(params[:organizational_label])
        render json: @organizational_label,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      else
        render json: {errors: @organizational_label.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def destroy
    if @organizational_label.organization_id != 0
      @organizational_label.update_attribute(:removed_date, Date.today)
      render json: @organizational_label,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    end
  end


  def bulk
    remove_labels(filtered_people, params[:remove_labels]) if params[:remove_labels].present?
    add_labels(filtered_people, params[:add_labels]) if params[:add_labels].present?

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_create
    add_labels(filtered_people, params[:labels]) if params[:labels].present?

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_destroy
    remove_labels(filtered_people, params[:labels]) if params[:labels].present?

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end


  private

  def people
    current_organization.people
  end

  def get_person
    if params[:id] == "me"
      @person = current_user.person
    else
      @person = add_includes_and_order(people).find(params[:id])
    end
  end

  def ensure_filters
    unless params[:filters]
      render json: {errors: ["The 'filters' parameter is required for bulk label actions."]},
                 status: :bad_request,
                 callback: params[:callback]
    end
  end

  def filtered_people
    unless @filtered_people
      @filtered_people = if params[:include_archived] == 'true'
        current_organization.people
      else
        current_organization.not_archived_people
      end

      @filtered_people = add_includes_and_order(@filtered_people)
      @filtered_people = PersonFilter.new(params[:filters]).filter(@filtered_people) if params[:filters]
    end
    @filtered_people
  end

  def add_labels(people, labels)
    current_organization.add_labels_to_people(filtered_people, labels.split(',')) if labels.present?
  end

  def remove_labels(people, labels)
    current_organization.remove_labels_from_people(filtered_people, labels.split(',')) if labels.present?
  end

  private

  def organizational_labels
    current_organization.organizational_labels
  end

  def get_org_label
    @organizational_label = add_includes_and_order(organizational_labels).find(params[:id])
  end
end
