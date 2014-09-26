class UpdatePeopleGender < ActiveRecord::Migration
  def up
    male_people = Person.where("gender = 'm' OR gender = 'M'")
    puts "Total people has 'm' or 'M' gender value have been updated in to '1'(Male): #{male_people.count}"
    male_people.update_all(gender: 1) if male_people.present?

    female_people = Person.where("gender = 'f' OR gender = 'F'")
    puts "Total people has 'f' or 'F' gender value have been updated in to '0'(Female): #{female_people.count}"
    female_people.update_all(gender: 0) if female_people.present?

    people_has_invalid_gender = Person.where("gender <> '1' AND gender <> '0' AND gender IS NOT NULL")
    puts "Total people has a random gender value have been updated in to NULL: #{people_has_invalid_gender.count}"
    people_has_invalid_gender.update_all(gender: nil) if people_has_invalid_gender.present?
  end

  def down
  end
end
