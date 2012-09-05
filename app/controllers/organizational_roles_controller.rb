class OrganizationalRolesController < ApplicationController
  cache_sweeper :organization_sweeper, only: [:update, :destroy, :create]

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
        render :text => I18n.t('organizational_roles.moving_people_success')
        return
      end
    end
    
    render :text => I18n.t('organizational_roles.moving_to_same_org')
  end
end
