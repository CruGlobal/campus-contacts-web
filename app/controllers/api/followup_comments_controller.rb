class Api::FollowupCommentsController < ApiController
  oauth_required scope: "followup_comments"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header

  def create_1
      begin
      @json = ActiveSupport::JSON.decode(params[:json])
    rescue 
      raise InvalidJSONError
    end

    raise FollowupCommentCreateParamsError if @json['rejoicables'].nil? || @json['followup_comment'].blank?
    @json['followup_comment']['organization_id'] ||= @organization.id
    
    @followup_comment = FollowupComment.create(@json['followup_comment'])

    @json['rejoicables'].each do |what|
      if Rejoicable::OPTIONS.include?(what)
        @followup_comment.rejoicables.create(what: what, created_by_id: current_person.id, person_id: @followup_comment.contact_id, organization_id: @followup_comment.organization_id)
      end
    end if @json['rejoicables']
    render json: "[]"
  end
  
  def show_1
    contact_id = params[:id].present? ? params[:id] : 0
    @followup_comments = FollowupComment.includes(:rejoicables).where(contact_id: contact_id).where(organization_id: @organization.id).order("created_at DESC")
    json_output = @followup_comments.collect {|c| {followup_comment: {comment: c.to_hash, rejoicables: c.rejoicables.collect{|y| y.attributes.slice('id','what')}}}}
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def show_2
    json_output = @api_json_header
    contact_id = params[:id].present? ? params[:id] : 0
    
    @followup_comments = FollowupComment.unscoped.includes(:rejoicables).where(contact_id: contact_id).where(organization_id: @organization.id)
    if (params[:since].present?)
      @followup_comments = @followup_comments.where("followup_comments.updated_at >= ?", Time.at(params[:since].to_i).utc)
    end
    if (params[:until].present?)
      @followup_comments = @followup_comments.where("followup_comments.updated_at < ?", Time.at(params[:until].to_i).utc)
    end
    
    @followup_comments = @followup_comments.order("created_at DESC")
        
    json_output[:followup_comments] = @followup_comments.collect {|c| {followup_comment: {comment: c.to_hash, rejoicables: c.rejoicables.collect{|y| y.attributes.slice('id','what')}}}}
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def destroy_1
    raise FollowupCommentDeleteParamsError unless (params[:id].present? && (is_int?(params[:id]) || (params[:id].is_a? Array)))
    ids = params[:id].split(',')
    
    comments = FollowupComment.where(id: ids)
    role = current_person.organizational_roles.where(organization_id: @organization.id).collect(&:role).collect(&:i18n)
    
    comments.each_with_index do |comment,i|
      if role[i] == 'leader'
        raise FollowupCommentPermissionsError unless comment.commenter_id == current_person.id
      elsif role[i] == 'admin'
        raise FollowupCommentPermissionsError unless comment.organization_id == @organization.id
      else
        raise FollowupCommentPermissionsError
      end
    end
    
    comments.destroy_all
    render :json => '[]'
  end
end
