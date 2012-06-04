class OrganizationalRolesController < ApplicationController
  def update
    @organizational_role = OrganizationalRole.find(params[:id])
    @organizational_role.followup_status = params[:status]
    if params[:status] == 'do_not_contact'
      person_id = @organizational_role.person_id
      organization_id = @organizational_role.organization_id
      
      contact_assignments = ContactAssignment.where(person_id: person_id, organization_id: organization_id)
      survey_ids = Survey.where(organization_id: organization_id).collect{|s| s.id}
      answer_sheets = AnswerSheet.where(survey_id: survey_ids, person_id: person_id)
      answer_sheets_ids = answer_sheets.collect{|a| a.id}
      answers = Answer.where(answer_sheet_id: answer_sheets_ids)
      
      
      Rails.logger.info ""
      Rails.logger.info "Delete #{contact_assignments.count} Contact Assignments"
      Rails.logger.info "Delete #{answer_sheets.count} Answer Sheets"
      Rails.logger.info "Delete #{answers.count} Answers"
      Rails.logger.info ""
      
    end
    # @organizational_role.save
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
