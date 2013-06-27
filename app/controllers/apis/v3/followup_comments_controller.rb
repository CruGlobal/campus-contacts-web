class Apis::V3::FollowupCommentsController < Apis::V3::BaseController
  before_filter :get_followup_comment, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'created_at desc'

    render json: custom_followup_comments,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: fake_serialize(@followup_comment),
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    custom_attr = translate_followup_comment_to_interaction(params[:followup_comment])
    followup_comment = Interaction.new(custom_attr)
    followup_comment.organization_id = current_organization.id
    followup_comment.interaction_type_id = InteractionType.comment.id
    if followup_comment.save
      if params[:followup_comment][:status].present?
        person = followup_comment.receiver
        org_permission = person.organizational_permission_for_org(current_organization)
        unless org_permission.present?
          current_organization.add_contact(person)
          org_permission = person.organizational_permission_for_org(current_organization)
        end
        org_permission.update_attribute(:followup_status, params[:followup_comment][:status])
      end
      render json: fake_serialize(followup_comment),
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: followup_comment.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    custom_attr = translate_followup_comment_to_interaction(params[:followup_comment])
    if @followup_comment.update_attributes(custom_attr)
      if params[:followup_comment][:status].present?
        person = @followup_comment.receiver
        org_permission = person.organizational_permission_for_org(current_organization)
        unless org_permission.present?
          current_organization.add_contact(person)
          org_permission = person.organizational_permission_for_org(current_organization)
        end
        org_permission.update_attribute(:followup_status, params[:followup_comment][:status])
      end
      render json: fake_serialize(@followup_comment),
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: followup_comment.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    @followup_comment.destroy
    render json: fake_serialize(@followup_comment),
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def custom_followup_comments
    custom = Hash.new
    interactions = []
    current_organization.interactions.limit(5).each do |i|
      interactions << translate_interaction_to_followup_comment(i)
    end
    custom['followup_comments'] = interactions
    return custom
  end

  def translate_interaction_to_followup_comment(object)
    followup_comment = {}
    followup_comment['id'] = object.id
    followup_comment['contact_id'] = object.receiver_id
    followup_comment['commenter_id'] = object.created_by_id
    followup_comment['comment'] = object.comment
    followup_comment['status'] = object.receiver.organizational_permission_for_org(current_organization).try(:followup_status)
    followup_comment['organization_id'] = object.organization_id
    followup_comment['updated_at'] = object.updated_at
    followup_comment['created_at'] = object.created_at
    followup_comment['deleted_at'] = object.deleted_at
    return followup_comment
  end

  def translate_followup_comment_to_interaction(object)
    interaction_hash = {}
    interaction_hash['receiver_id'] = object['contact_id'].to_i if object['contact_id'].present?
    interaction_hash['created_by_id'] = object['commenter_id'].to_i if object['commenter_id'].present?
    interaction_hash['comment'] = object['comment'] if object['comment'].present?
    interaction_hash['deleted_at'] = object['deleted_at'] if object['deleted_at'].present?
    return interaction_hash
  end

  def fake_serialize(content)
    {'followup_comment' => translate_interaction_to_followup_comment(content)}
  end

  def followup_comments
    current_organization.followup_comments
  end

  def get_followup_comment
    @followup_comment = current_organization.interactions.find(params[:id])
  end

end
