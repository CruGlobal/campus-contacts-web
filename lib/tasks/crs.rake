namespace :crs do
  task "recruit" => :environment do
    sql = 'SELECT ministry_person.id as person_id, ministry_person.universityState, ministry_person.graduation_date, crs2_conference.name AS conference_name, crs2_conference.region AS region, crs2_question.name as interest
    FROM ((((crs2_answer 
      INNER JOIN crs2_custom_questions_item ON crs2_answer.question_usage_id = crs2_custom_questions_item.id) 
      INNER JOIN crs2_question ON crs2_custom_questions_item.question_id = crs2_question.id) 
      INNER JOIN (crs2_registrant 
        INNER JOIN (crs2_registrant_type 
          INNER JOIN crs2_conference ON crs2_registrant_type.conference_id = crs2_conference.id) ON crs2_registrant.registrant_type_id = crs2_registrant_type.id) ON crs2_answer.registrant_id = crs2_registrant.id) 
          INNER JOIN crs2_profile ON crs2_registrant.profile_id = crs2_profile.id) 
          INNER JOIN ministry_person ON crs2_profile.ministry_person_id = ministry_person.id 
          WHERE crs2_registrant.status="Complete" AND 
             ((crs2_question.name = "OpsInterest" AND (crs2_answer.value_string = "Yes" OR crs2_answer.value_boolean = 1))
          OR  (crs2_question.name ="OpsTechnology" AND crs2_answer.value_boolean = 1)
          OR  (crs2_question.name ="OpsFinance" AND crs2_answer.value_boolean = 1) 
          OR  (crs2_question.name = "OpsMedia" AND  crs2_answer.value_boolean = 1) 
          OR  (crs2_question.name = "OpsEventPlanning" AND  crs2_answer.value_boolean = 1) 
          OR  (crs2_question.name = "OpsCommunication" AND crs2_answer.value_boolean = 1))
    ORDER BY ministry_person.last_name, crs2_conference.name'
    survey_id = 381
    survey = Survey.find(survey_id)
    org = survey.organization
    grad_q = Element.find(2186)
    contact_q = Element.find(2183)
    conference_q = Element.find(2517)
    interest_q = Element.find(2187)
    interest_map = {'OpsOther' => 'Other', 
                    'OpsTechnology' => 'Technology', 
                    'OpsFinance' => 'Finance', 
                    'OpsMedia' => 'Media',
                    'OpsEventPlanning' => 'Event Planning',
                    'OpsCommunication' => 'Communication'}
    state_q = Element.find(2182)
    # First group answers
    people = {}
    ActiveRecord::Base.connection.select_all(sql).each do |row|
      people[row['person_id']] ||= {}
      people[row['person_id']]['grad'] = row['graduation_date'].year if row['graduation_date']
      people[row['person_id']]['state'] = row['universityState']
      people[row['person_id']]['conference_name'] = row['conference_name']
      people[row['person_id']]['interest'] ||= []
      if row['interest'] == 'OpsInterest'
        people[row['person_id']]['contact_me'] = true
      else
        people[row['person_id']]['interest'] << interest_map[row['interest']]
      end
    end
    people.each do |person_id, answers|
      if answers['contact_me']
        answer_sheet = AnswerSheet.find_or_create_by_person_id_and_survey_id(person_id, survey_id)
      
        if answers['grad']
          grad_answer = Answer.find_or_create_by_answer_sheet_id_and_question_id(answer_sheet.id, grad_q.id)
          grad_answer.update_attribute(:value, answers['grad'])
        end
      
        Answer.where(:answer_sheet_id => answer_sheet.id, :question_id => interest_q.id).delete_all
        answers['interest'].each do |interest|
          interest_answer = Answer.create(:answer_sheet_id => answer_sheet.id, :question_id => interest_q.id, :value => interest || 'Other')
        end
      
        state_answer = Answer.find_or_create_by_answer_sheet_id_and_question_id(answer_sheet.id, state_q.id)
        state_answer.update_attribute(:value, answers['state'])
        
        conference_answer = Answer.find_or_create_by_answer_sheet_id_and_question_id(answer_sheet.id, conference_q.id)
        conference_answer.update_attribute(:value, answers['conference_name'])
        
        contact_answer = Answer.find_or_create_by_answer_sheet_id_and_question_id(answer_sheet.id, contact_q.id)
        contact_answer.update_attribute(:value, answers['contact_me'] ? 'Yes' : 'No')
      
        # Add to org
        org.add_contact(person_id)
      end
    end
  end
  
  task "phone" => :environment do
    # Update cell phone numbers
    question_usage_ids = [16531, 15536, 19668, 16196, 16182, 16165, 16143, 16136]
    question_usage_ids.each do |question_usage_id|
      sql = "select value_string, id from crs2_answer a left join crs2_registrant r on a.registrant_id = r.id left join crs2_profile p on r.profile_id = p.id left join ministry_person mp on p.ministry_person_id = mp.id where a.question_usage_id = #{question_usage_id} AND value_string IS NOT NULL and id is not null"
      ActiveRecord::Base.connection.select_all(sql).each do |row|
        num = row['value_string']
        stripped_num = num.to_s.gsub(/[^\d]/, '')
        if stripped_num.length == 10
          person = Person.find(row['id'])
          person.phone_numbers.find_by_number(stripped_num) || person.phone_numbers.create(number: stripped_num, location: 'mobile')
        end
      end
    end
  end
end