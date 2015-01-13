class FixDataEnsureSinglePrimaryEmail < ActiveRecord::Migration
  def up
    EmailAddress.where(email: "").destroy_all
    EmailAddress.where(email: nil).destroy_all
    people = Person.joins("JOIN email_addresses ON email_addresses.person_id = people.id").select("people.id").where("email_addresses.primary = 1").group("email_addresses.person_id").having("COUNT(*) > 1")
    puts "Fixing #{people.length} people..."
    people.each do |person|
      emails = EmailAddress.where(person_id: person.id)
      puts "Working on Person##{person.id}:"
      if emails.where(primary: 1)
        first_email = emails.where(primary: 1).last
        fe = first_email.email.downcase if first_email.email.present?
        puts "  Fix #{fe}: Current Primary (ignore)"
      else
        first_email = emails.last
        first_email.update_attributes(primary: 1)
        fe = first_email.email.downcase if first_email.email.present?
        puts "  Fix #{fe}: New Primary (update)"
      end
      first_email.update_attributes(email: fe.gsub(",","."))
      emails.each do |email|
        email.update_attributes(email: email.email.gsub(",","."))
        if email != first_email
          e = email.email.downcase
          if e == fe
            email.destroy
            puts "  Fix #{e}: Duplicate (delete)"
          else
            email.update_attributes(primary: 0)
            puts "  Fix #{e}: Multiple Primary (update)"
          end
        end
      end
    end
  end

  def down
  end
end
