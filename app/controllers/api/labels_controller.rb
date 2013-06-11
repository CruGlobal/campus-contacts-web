class Api::LabelsController < ApiController
  oauth_required scope: "labels"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  before_filter :ensure_valid_request

  def update_1
    @person = Person.find(params[:id])
    @organization.send("add_#{params[:label]}".to_sym, @person, current_person)
    render json: '[]'
  end

  def destroy_2
    @person = Person.find(params[:id])
    @organization.send("remove_#{params[:label]}".to_sym, @person)
    render json: '[]'
  end


  protected

  def ensure_valid_request
    raise InvalidLabelsParamaters unless params[:id].present? && params[:label].present? && params[:org_id].present?
    raise LabelsError if current_person.organizational_labels.where(organization_id: @organization.id, label_id: Label::LEADER_ID).empty?
    raise NoLabelChangeMade unless Label.default.collect(&:i18n).include?(params[:label])
  end

end
