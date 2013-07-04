class Api::InteractionsController < ApiController
  oauth_required scope: "interactions"
  before_filter :valid_request_before, :authorized_leader?, :organization_allowed?, :get_organization, :get_api_json_header

  def create_1
    begin
      @json = ActiveSupport::JSON.decode(params[:json])
    rescue 
      raise InvalidJSONError
    end

    raise InteractionCreateParamsError if @json['interaction'].blank?
    @json['interaction']['organization_id'] ||= @organization.id
    @json['interaction']['receiver_id'] ||= 0
    @interaction = Interaction.create(@json['interaction'])
    render json: "[]"
  end
  
  def show_1
    if params[:id].present?
      contact_id = clean_id(params[:id])
      json_output = Interaction.get_interactions_hash(contact_id, current_organization.id)
      final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
      final_output
    else
      final_output = "[]"
    end
    render json: final_output
  end
  
  def show_2
    json_output = @api_json_header
    contact_id = clean_id(params[:id])
    
    @interactions = Interaction.where(receiver_id: contact_id, organization_id: current_organization.id)
    if (params[:since].present?)
      @interactions = @interactions.where("interactions.updated_at >= ?", Time.at(params[:since].to_i).utc)
    end
    if (params[:until].present?)
      @interactions = @interactions.where("interactions.updated_at < ?", Time.at(params[:until].to_i).utc)
    end
    
    @interactions = @interactions.order("created_at DESC")
        
    json_output[:interaction] = @interactions.collect(&:to_hash)
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def destroy_1
    raise InteractionDeleteParamsError unless (params[:id].present? && (is_int?(params[:id]) || (params[:id].is_a? Array)))
    ids = params[:id].split(',')
    
    interactions = Interaction.where(id: ids)
    permission = current_person.organizational_permissions.where(organization_id: @organization.id).collect(&:permission).collect(&:i18n)
    
    interactions.each_with_index do |interaction,i|
      if permission[i] == 'user'
        raise InteractionPermissionsError unless interaction.created_by_id == current_person.id
      elsif permission[i] == 'admin'
        raise InteractionPermissionsError unless interaction.organization_id == @organization.id
      else
        raise InteractionPermissionsError
      end
    end
    
    interactions.destroy_all
    render :json => '[]'
  end
  
  def clean_id(id)
    case id
    when "me"
      contact_id = current_person.id
    when "anonymous"
      contact_id = 0
    else 
      id.to_i
    end
  end
end
