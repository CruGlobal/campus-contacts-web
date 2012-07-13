class OrganizationalRolesController < ApplicationController
  def update
    @organizational_role = OrganizationalRole.find(params[:id])
    @organizational_role.followup_status = params[:status]
    if params[:status] == 'do_not_contact'
      person_id = @organizational_role.person_id
      organization_id = @organizational_role.organization_id
      
      # Delete Contact Assignments
      contact_assignments = ContactAssignment.where(person_id: person_id, organization_id: organization_id)
      contact_assignments_count = contact_assignments.count
      contact_assignments.destroy_all
      
      # Delete Answer Sheets & Answers
      survey_ids = Survey.where(organization_id: organization_id).collect{|s| s.id}
      answer_sheets = AnswerSheet.where(survey_id: survey_ids, person_id: person_id)
      answer_sheets_ids = answer_sheets.collect{|a| a.id}
      answers = Answer.where(answer_sheet_id: answer_sheets_ids)
      answers_count = answers.count
      answers.destroy_all
      answer_sheets_count = answer_sheets.count
      answer_sheets.destroy_all
      
      # Delete Followup Comments
      followup_comments = FollowupComment.where(contact_id: person_id, organization_id: organization_id)
      followup_comments_count = followup_comments.count
      followup_comments.destroy_all
      
      # Delete Group Membership
      group_ids = Group.where(organization_id: organization_id).collect{|g| g.id}
      group_memberships = GroupMembership.where(group_id: group_ids, person_id: person_id)
      group_memberships_count = group_memberships.count
      group_memberships.destroy_all
      
      Rails.logger.info ""
      Rails.logger.info ""
      Rails.logger.info ""
      Rails.logger.info "Delete #{contact_assignments_count} Contact Assignments"
      Rails.logger.info "Delete #{answers_count} Answers"
      Rails.logger.info "Delete #{answer_sheets_count} Answer Sheets"
      Rails.logger.info "Delete #{followup_comments_count} Followup Comments"
      Rails.logger.info "Delete #{group_memberships_count} Group Memberships"
      Rails.logger.info ""
      Rails.logger.info ""
      Rails.logger.info ""
      
    end
    @organizational_role.save
    respond_to do |wants|
      wants.html
      wants.js {render nothing: true}
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
