class OrganizationalRolesController < ApplicationController
  def update
    @organizational_role = OrganizationalRole.find(params[:id])
    @organizational_role.followup_status = params[:status]
    if params[:status] == 'do_not_contact'
      person_id = @organizational_role.person_id
      organization_id = @organizational_role.organization_id
      
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
        people = Person.find(params[:ids])

        people.each do |person|
          from_org.move_contact(person, to_org, keep_contact, current_person)
        end
      end
    end
    render nothing: true
  end
end
