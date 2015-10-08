class ProfileController < ApplicationController
  before_action :authorize
  skip_before_action :clear_advanced_search

  def show
    permissions_for_assign
    groups_for_assign
    labels_for_assign

    @person = current_person.id == params[:id].to_i ? current_person : current_organization.people.where(id: params[:id]).first
    if @person.present?
      # Ensure single permission
      @person.ensure_single_permission_for_org_id(current_organization.id)
      @interaction = Interaction.new
      @completed_answer_sheets = @person.completed_answer_sheets(current_organization).order('completed_at DESC')

      @labels = @person.assigned_organizational_labels(current_organization.id).uniq
      @permission = @person.assigned_organizational_permissions(current_organization.id).first
      @groups = @person.groups_for_org_id(current_organization.id)
      @assigned_tos = @person.assigned_to_people_by_org(current_organization)
      @friends = @person.friends_in_orgnization(current_organization)
      @received_emails = @person.received_messages_in_org(current_organization.id)
      if can? :manage, @person
        @interactions = @person.filtered_interactions(current_person, current_organization)
        @last_interaction = @interactions.last
        @interactions = @interactions.limited

        @all_feeds_page = 1
        @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
        @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
      end
    else
      redirect_to all_contacts_path
    end
  end

  def change_avatar
    @person = Person.find(params[:id])
    if @person.present? && params[:person].present?
      if params[:person][:fb_uid].present? && @person.fb_uid.to_s != params[:person][:fb_uid]
        @person.update_attributes(fb_uid: params[:person][:fb_uid], avatar: nil)
      else
        @person.update_attributes(params[:person])
        @msg = I18n.t('dialogs.dialog_avatar.invalid_format') if @person.invalid?
      end
    end
    redirect_to :back, notice: @msg || nil
  end

  def remove_avatar
    @person = Person.find(params[:id])
    if @person.present?
      @person.fb_uid = nil if @person.fb_uid.present?
      @person.avatar.destroy if @person.avatar.exists?
      @person.save
    end
    redirect_to :back
  end

  def remove_facebook
    @person = Person.find(params[:id])
    @person.update_attributes(fb_uid: nil) if @person.present? && @person.fb_uid.present?
    redirect_to :back, notice: I18n.t('interactions.profile_info.success_remove_facebook')
  end

  protected

  def authorize
    authorize! :manage_contacts, current_organization
  end
end
