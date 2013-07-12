class Label < ActiveRecord::Base
end
class OrganizationalLabel < ActiveRecord::Base
end
class Person < ActiveRecord::Base
end
class Interaction < ActiveRecord::Base
end
class InteractionType < ActiveRecord::Base
end
class InteractionInitiator < ActiveRecord::Base
end
class RemoveSentLabel < ActiveRecord::Migration
  def up
    sent_labels = Label.where("name = '100% Sent' AND organization_id <> 0")
    if sent_labels.present?
      sent_labels.each do |sent_label|
        org = sent_label.organization
        puts "Cleaning 100% Sent label from Organization##{org.id}"
        org_labels = OrganizationalLabel.where(organization_id: org.id, label_id: sent_label.id)
        org_labels.each do |org_label|
          puts "Delete '#{sent_label.name}' label for Person##{org_label.person_id}"
          org_label.destroy
        end
        puts "Delete '#{sent_label.name}' label"
        sent_label.destroy
      end
      puts "Cleaning Complete!"
    else
      raise "100% Sent label not found!"
    end
    default_sent_label = Label.find_by_i18n('sent')
    default_sent_label.destroy if default_sent_label.present?
  end

  def down
  end
end
