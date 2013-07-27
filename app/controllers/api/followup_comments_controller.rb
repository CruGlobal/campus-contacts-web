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

      if @json['rejoicables'].empty?
        create_interaction(@json['followup_comment'])
      else
        @json['rejoicables'].each do |what|
          create_interaction(@json['followup_comment'], what)
        end
      end

    render json: []
  end

  def show_1
    contact = Person.find_by_id(params[:id]) if params[:id].present?
    comments = []
    if contact
      interactions = contact.filtered_interactions(current_person, @organization)
      comments = interactions.collect { |interaction|
        {followup_comment: hash_interaction_to_followup_comment(interaction) }
      }
    end
    final_output = Rails.env.production? ? JSON.fast_generate(comments) : JSON::pretty_generate(comments)
    render json: final_output
  end

  def show_2
    json_output = @api_json_header
    contact = Person.find_by_id(params[:id]) if params[:id].present?
    comments = []
    if contact
      interactions = contact.filtered_interactions(current_person, @organization)
      if params[:since].present?
        interactions = interactions.where("interactions.updated_at >= ?", Time.at(params[:since].to_i).utc)
      end
      if (params[:until].present?)
        interactions = interactions.where("interactions.updated_at < ?", Time.at(params[:until].to_i).utc)
      end
      interactions = interactions.order("created_at DESC")
      json_output[:followup_comments] = interactions.collect { |interaction|
        {followup_comment: hash_interaction_to_followup_comment(interaction) }
      }
    end
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end

  def destroy_1
    raise FollowupCommentDeleteParamsError unless (params[:id].present? && (is_int?(params[:id]) || (params[:id].is_a? Array)))
    ids = params[:id].split(',')

    comments = Interaction.where(id: ids)
    permission = current_person.organizational_permissions.where(organization_id: @organization.id).collect(&:permission).collect(&:i18n)

    comments.each_with_index do |comment,i|
      if permission[i] == 'user'
        raise FollowupCommentPermissionsError unless comment.created_by_id == current_person.id
      elsif permission[i] == 'admin'
        raise FollowupCommentPermissionsError unless comment.organization_id == @organization.id
      else
        raise FollowupCommentPermissionsError
      end
      comment.destroy
    end

    render :json => '[]'
  end

  private

  def hash_interaction_to_followup_comment(object)
    comment = {}
    comment['id'] = object.id
    comment['contact_id'] = object.receiver_id
    comment['commenter'] = {
        'id' => object.creator.id,
        'name' => object.creator.name,
        'picture' => object.creator.picture,
    }
    comment['comment'] = object.comment
    comment['status'] = object.receiver.organizational_permission_for_org(@organization).try(:followup_status)
    comment['organization_id'] = object.organization_id
    comment['updated_at'] = object.updated_at
    comment['created_at'] = object.created_at
    comment['deleted_at'] = object.deleted_at
    comment['created_at_words'] = object.updated_at

    rejoicables = []
    if object.interaction_type_id.in?([2, 3, 4])
      rejoicables << {'id' => object.id, 'what' => translate_type_to_what(object.interaction_type.i18n)}
    elsif object.interaction_type_id != 1
      comment['comment'] = "Interaction: #{object.interaction_type.name}\n#{comment['comment']}"
    end

    return {comment: comment, rejoicables: rejoicables}
  end

  def translate_type_to_what(what)
    case what
      when 'prayed_to_receive_christ'
        'prayed_to_receive'
      else
        what
    end
  end

  def translate_what_to_type_id(what)
    case what
      when 'prayed_to_receive'
        4
      else
        type = InteractionType.find_by_i18n(what)
        if type
          type.id
        else
          1
        end
    end
  end

  def create_interaction(comment_json, what = 'comment')
    attributes = {}
    attributes[:interaction_type_id] = translate_what_to_type_id(what)
    attributes[:receiver_id] = comment_json['contact_id']
    attributes[:organization_id] = comment_json['organization_id']
    attributes[:created_by_id] = comment_json['commenter_id']
    attributes[:comment] = comment_json['comment']
    attributes[:privacy_setting] = 'everyone'

    unless what == 'comment' && attributes[:comment].blank?
      interaction = Interaction.new(attributes)
      if interaction.save
        interaction.set_initiators([current_person.id])
      else
        raise FollowupCommentCreateParamsError
      end
    end

    if comment_json['status'].present?
      receiver = Person.find(attributes[:receiver_id])
      if receiver
        receiver.set_followup_status(Organization.find(comment_json['organization_id']), comment_json['status'])
      end
    end
  end

end
