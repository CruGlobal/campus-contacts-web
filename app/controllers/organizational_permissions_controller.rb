class OrganizationalPermissionsController < ApplicationController

  def update_all
    permission_ids = params[:labels]
    person = Person.find(params[:id])
    if permission_ids.present?
      person.organizational_permissions(current_organization.id).where('permission_id NOT IN (?)', permission_ids).update_all({archive_date: Date.today})

      permission_ids.each do |permission_id|
        if permission_id.present?
          org_permission = OrganizationalPermission.find_or_create_by_person_id_and_organization_id_and_permission_id(person.id, current_organization.id, permission_id)
          org_permission.update_attributes({archive_date: nil, added_by_id: current_user.person.id, deleted_at: nil})
        end
      end
    else
      # We don't want to remove all of a person's permissions using this method.
    end
    @new_label_set = (person.assigned_organizational_permissions(current_organization.id).default_permissions + person.assigned_organizational_permissions(current_organization.id).non_default_permissions).collect(&:name)
  end

  def update
    @organizational_permission = OrganizationalPermission.find(params[:id])
    @organizational_permission.followup_status = params[:status] #set contact permission as "do_not_contact"

    if params[:status] == 'do_not_contact'
      person_id = @organizational_permission.person_id
      organization_id = @organizational_permission.organization_id

      Person.find(person_id).organizational_permissions.where(organization_id: current_organization.id).each do |ors|
        if(ors.permission_id == Permission::USER_ID)
          ca = Person.find(person_id).contact_assignments.where(organization_id: current_organization.id).all
          ca.collect(&:destroy)
        end
        ors.update_attributes({:followup_status => "do_not_contact"})
      end

      # Delete Contact Assignments
      contact_assignments = ContactAssignment.where(person_id: person_id, organization_id: organization_id)
      contact_assignments.destroy_all

      # Delete Answer Sheets & Answers
      survey_ids = Survey.where(organization_id: organization_id).collect(&:id)
      answer_sheets = AnswerSheet.where(survey_id: survey_ids, person_id: person_id)
      answer_sheets_ids = answer_sheets.collect(&:id)
      answers = Answer.where(answer_sheet_id: answer_sheets_ids)
      answers.destroy_all
      answer_sheets.destroy_all

      # Delete Followup Comments
      followup_comments = FollowupComment.where(contact_id: person_id, organization_id: organization_id)
      followup_comments.destroy_all

      # Delete Group Membership
      group_ids = Group.where(organization_id: organization_id).collect(&:id)
      group_memberships = GroupMembership.where(group_id: group_ids, person_id: person_id)
      group_memberships.destroy_all

    end
    @organizational_permission.save
    respond_to do |format|
      format.html
      format.js {render nothing: true}
    end
  end

  def move_to
    Organization.transaction do
      from_org = Organization.find(params[:from_id])
      to_org = Organization.find(params[:to_id])
      keep_contact = params[:keep_contact]

      unless from_org == to_org
        ids = params[:ids].to_s.split(',')
        people = Person.find(ids)

        if keep_contact == "false"
          if from_org.attempting_to_delete_or_archive_current_user_self_as_admin?(people.collect(&:id), current_person)
            render :text => I18n.t('organizational_permissions.cannot_delete_self_as_admin_error')
            return
          elsif i = from_org.attempting_to_delete_or_archive_all_the_admins_in_the_org?(people.collect(&:id))
            render :text => I18n.t('organizational_permissions.cannot_delete_admin_error', names: Person.find(i).collect(&:name).join(", "))
            return
          end
        end

        people.each do |person|
          from_org.move_contact(person, to_org, keep_contact, current_person)
        end
        render :text => keep_contact == "false" ? I18n.t('organizational_permissions.moving_people_success') : I18n.t('organizational_permissions.copy_people_success')
        return
      end
    end

    render :text => I18n.t('organizational_permissions.moving_to_same_org')
  end


  def set_current
    org = Organization.find(params[:id])
    orgs_i_have_access_to = current_person.organizations.collect {|o| o.subtree_ids}.flatten
    if orgs_i_have_access_to.include?(org.id)
      session[:current_organization_id] = params[:id]
    end
    redirect_to '/dashboard'
  end

  def set_primary
    org = Organization.find(params[:id])
    current_person.primary_organization = org
    session[:current_organization_id] = params[:id]
    redirect_to request.referrer ? :back : '/contacts'
  end
end
