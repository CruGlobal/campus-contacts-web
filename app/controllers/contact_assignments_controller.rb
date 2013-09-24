class ContactAssignmentsController < ApplicationController

  def create
    @organization = params[:org_id].present? ? Organization.find(params[:org_id]) : current_organization
    org_ids = params[:subs] == 'true' ? @organization.self_and_children_ids : @organization.id
    @people_scope = Person.where('organizational_permissions.organization_id' => org_ids).includes(:organizational_permissions_including_archived)
    @people_scope = @people_scope.where(id: @people_scope.archived_not_included.collect(&:id)) if params[:include_archived].blank? && params[:archived].blank?

    # @keyword = SmsKeyword.find(params[:keyword])
    # if params[:ids].present? && ENV["RAILS_ENV"] != "test"
      # if params[:assigned_to].present? && params[:assign_to].present?
      # if params[:from].present?
      #   assigned_tos = params[:from].split(",")
      #   ContactAssignment.where(person_id: params[:ids], assigned_to_id: assigned_tos,
      #     organization_id: @organization.id).destroy_all
      # else
      #   ContactAssignment.where(person_id: params[:ids], organization_id: @organization.id).destroy_all
      # end
    # end

    if params[:assign_to].present?
      if params[:assign_to] == "do_not_contact"
        params[:ids].each do |id|
          om = OrganizationalPermission.find_by_person_id_and_organization_id_and_permission_id(id, @organization.id, Permission::NO_PERMISSIONS_ID)
          Person.find(id).do_not_contact(om.id) if om.present?
        end if params[:ids].present?
        @reload_sidebar = true
      else
        @assign_to = Person.find(params[:assign_to])
        params[:ids].each do |id|
          ContactAssignment.find_or_create_by_person_id_and_organization_id_and_assigned_to_id(id, @organization.id, @assign_to.id)
        end if params[:ids].present?
        @reload_sidebar = true
      end
    else
      ContactAssignment.where(person_id: params[:ids], organization_id: @organization.id).destroy_all
      @reload_sidebar = true
    end

    # proceed only if we're not bulk assinging contacts to the DNC list
    if params[:assign_to] != "do_not_contact"
      # if you're assigning this person and their status is DNC, change it back to their prior status or uncontacted
      org_permissions = OrganizationalPermission.where(person_id: params[:ids], organization_id: @organization.id, permission_id: Permission::NO_PERMISSIONS_ID, followup_status: 'do_not_contact')
      org_permissions.each do |permission|
        status = FollowupComment.where(contact_id: permission.person_id, organization_id: permission.organization_id).where("status <> 'do_not_contact'").order('created_at').last.try(:status)
        status = 'uncontacted' unless status.present?
        permission.update_attribute(:followup_status, status)
        @reload_sidebar = true
      end
    end

    # Profile
    if params[:ids].present?
      @person = current_organization.people.where(id: params[:ids].first).try(:first)
      if @person.present?
        @assigned_tos = @person.assigned_to_people_by_org(current_organization)
      end
    end

    unless @reload_sidebar
      render nothing: true
    end
  end

  def destroy
    if params[:ids].present?
      if params[:from].present?
        assigned_tos = params[:from].split(",")
        ContactAssignment.where(person_id: params[:ids], assigned_to_id: assigned_tos,
          organization_id: current_organization.id).destroy_all
      else
        ContactAssignment.where(person_id: params[:ids], organization_id: current_organization.id).destroy_all
      end
      @person = current_organization.people.where(id: params[:ids].first).try(:first)
      if @person.present?
        @assigned_tos = @person.assigned_to_people_by_org(current_organization)
      end
    end
  end


end
