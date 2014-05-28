class RemoveUnnamedPeople < ActiveRecord::Migration
  def up
    people = Person.where(first_name: "please enter your first name")
    people.each do |person|
      OrganizationalPermission.where(person_id: person.id).destroy_all
      OrganizationalLabel.where(person_id: person.id).destroy_all
      ContactAssignment.where(assigned_to_id: person.id).destroy_all
      ContactAssignment.where(person_id: person.id).destroy_all
      Address.where(person_id: person.id).destroy_all
      PhoneNumber.where(person_id: person.id).destroy_all
      Location.where(person_id: person.id).destroy_all
      Interest.where(person_id: person.id).destroy_all
      EducationHistory.where(person_id: person.id).destroy_all
      FollowupComment.where(contact_id: person.id).destroy_all
      FollowupComment.where(commenter_id: person.id).destroy_all
      EmailAddress.where(person_id: person.id).destroy_all
      Interaction.where(receiver_id: person.id).destroy_all
      GroupMembership.where(person_id: person.id).destroy_all
      SmsSession.where(person_id: person.id).destroy_all

      ans_sheets = AnswerSheet.where(person_id: person.id)
      ans_sheets.each do |ans_sheet|
        ans_sheet.answers.destroy_all
      end
      ans_sheets.destroy_all

      if person.user_id.present? && usr = User.find(person.user_id)
        usr.destroy
      end

      person.destroy
      puts "Person##{person.id} and all its data has been deleted!"
    end
  end

  def down
  end
end
