class OrganizationalRolesController < ApplicationController
  cache_sweeper :organization_sweeper, only: [:update, :destroy, :create]
  
  def update_all
    role_ids = params[:labels]
    person = Person.find(params[:id])
    if role_ids.present?
      person.assigned_organizational_roles(current_organization.id).where('roles.id NOT IN (?)', role_ids).update_all({deleted: 1})
      
      role_ids.each do |role_id|
        if role_id.present?
          org_role = OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person.id, current_organization.id, role_id)
          org_role.update_attributes({deleted: 0, added_by_id: current_user.person.id}) if org_role.deleted == true
        end
      end
    else
      person.assigned_organizational_roles(current_organization.id).update_all({deleted: 1})
    end
    @new_label_set = (person.assigned_organizational_roles(current_organization.id).default_roles_desc + person.assigned_organizational_roles(current_organization.id).non_default_roles_asc).collect(&:name)
  end

  def update
    @organizational_role = OrganizationalRole.find(params[:id])
    @organizational_role.followup_status = params[:status] #set contact role as "do_not_contact"
    
    if params[:status] == 'do_not_contact'
      person_id = @organizational_role.person_id
      organization_id = @organizational_role.organization_id
      
      Person.find(person_id).organizational_roles.where(organization_id: current_organization.id).each do |ors|
        if(ors.role_id == Role::LEADER_ID)
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
    @organizational_role.save
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
            render :text => I18n.t('organizational_roles.cannot_delete_self_as_admin_error')
            return
          elsif i = from_org.attempting_to_delete_or_archive_all_the_admins_in_the_org?(people.collect(&:id))
            render :text => I18n.t('organizational_roles.cannot_delete_admin_error', names: Person.find(i).collect(&:name).join(", "))
            return
          end
        end
        
        people.each do |person|
          from_org.move_contact(person, to_org, keep_contact, current_person)
        end
        render :text => keep_contact == "false" ? I18n.t('organizational_roles.moving_people_success') : I18n.t('organizational_roles.copy_people_success')
        return
      end
    end
    
    render :text => I18n.t('organizational_roles.moving_to_same_org')
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
    expire_fragment("org_nav/#{current_person.id}")
    redirect_to request.referrer ? :back : '/contacts'
  end
end
