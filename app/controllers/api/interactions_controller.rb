class Api::InteractionsController < ApiController
  #oauth_required scope: "interactions"
  before_filter :valid_request_before, :authorized_leader?, :organization_allowed?, :get_organization, :get_api_json_header

  def create_1
    begin
      @json = ActiveSupport::JSON.decode(params[:json])
    rescue 
      raise InvalidJSONError
    end

    raise InteractionCreateParamsError if @json['followup_comment'].blank?
    @json['followup_comment']['organization_id'] ||= @organization.id
    @followup_comment = Interaction.create(@json['followup_comment'])
    render json: "[]"
  end
  
  def show_1
    contact_id = params[:id].present? ? params[:id] : 0
    @interactions = Interaction.where(receiver_id: params[:id], organization_id: @organization.id).order("created_at DESC")
    json_output = @interactions.collect {|c| {interaction: {id: c.id, interaction_type_id: c.interaction_type_id, receiver_id: c.receiver_id, initiator_ids: c.initiator_ids, organization_id: c.organization_id, created_by_id: c.created_by_id, comment: c.comment, privacy_setting: c.privacy_setting, timestamp: c.timestamp, created_at: c.created_at, updated_at: c.updated_at, deleted_at: c.deleted_at}}}
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def show_2
    json_output = @api_json_header
    contact_id = params[:id].present? ? params[:id] : 0
    
    @interaction = Interaction.unscoped.includes(:rejoicables).where(contact_id: contact_id).where(organization_id: @organization.id)
    if (params[:since].present?)
      @interaction = @interaction.where("interaction.updated_at >= ?", Time.at(params[:since].to_i).utc)
    end
    if (params[:until].present?)
      @interaction = @interaction.where("interaction.updated_at < ?", Time.at(params[:until].to_i).utc)
    end
    
    @interaction = @interaction.order("created_at DESC")
        
    json_output[:interaction] = @interaction.collect {|c| {followup_comment: {comment: c.to_hash, rejoicables: c.rejoicables.collect{|y| y.attributes.slice('id','what')}}}}
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def destroy_1
    raise InteractionDeleteParamsError unless (params[:id].present? && (is_int?(params[:id]) || (params[:id].is_a? Array)))
    ids = params[:id].split(',')
    
    comments = Interaction.where(id: ids)
    role = current_person.organizational_roles.where(organization_id: @organization.id).collect(&:role).collect(&:i18n)
    
    comments.each_with_index do |comment,i|
      if role[i] == 'missionhub_user'
        raise InteractionPermissionsError unless comment.commenter_id == current_person.id
      elsif role[i] == 'admin'
        raise InteractionPermissionsError unless comment.organization_id == @organization.id
      else
        raise InteractionPermissionsError
      end
    end
    
    comments.destroy_all
    render :json => '[]'
  end
end
