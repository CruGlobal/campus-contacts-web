class FixDataAddPermissionToFbUsersTakenTheSurveys < ActiveRecord::Migration
  def up
    AnswerSheet.where("DATE(created_at) >= '2015-04-22'").each do |answer_sheet|
      survey = answer_sheet.survey
      person = answer_sheet.person
      if survey.present? && person.present?
        organization = survey.organization
        if organization.present? && !person.all_organizational_permissions_for_org_id(organization.id).present?
          organization.add_contact(person)
        end
      end
    end
  end

  def down
  end
end
