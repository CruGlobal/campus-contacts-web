module ContactMethods
  def create_contact_at_org(person, organization, added_by_id = nil)
    # if someone already has a status in an org, we shouldn't add them as a contact
    raise 'no person' unless person
    raise 'no org' unless organization
    organization.add_contact(person, added_by_id)
  end

  def get_answer_sheet(survey, person)
    answer_sheet = AnswerSheet.where(person_id: person.id, survey_id: survey.id).first ||
                   AnswerSheet.create!(person_id: person.id, survey_id: survey.id)
    answer_sheet.reload
    answer_sheet
  end
end