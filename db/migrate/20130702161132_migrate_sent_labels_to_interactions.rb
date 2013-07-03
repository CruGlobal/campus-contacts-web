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
class MigrateSentLabelsToInteractions < ActiveRecord::Migration
  def up
    sent_label = Label.find_by_i18n('sent')
    if sent_label.present?
      graduating_on_mission_id = InteractionType.find_by_i18n('graduating_on_mission').try(:id)
      if graduating_on_mission_id.present?
        transfers = OrganizationalLabel.where(label_id: sent_label.id)
        puts "Migrating #{transfers.count} records"
        transfers.each_with_index do |org_label, i|
          interaction = Interaction.new(
            interaction_type_id: graduating_on_mission_id,
            receiver_id: org_label.person_id,
            created_by_id: org_label.added_by_id,
            organization_id: org_label.organization_id,
            privacy_setting: 'everyone',
            created_at: org_label.start_date,
            timestamp: org_label.start_date,
            deleted_at: org_label.removed_date
          )
          puts "#{i} - Moving OrganizatioanlLabel##{org_label.id} to Interaction"
          if interaction.save
            if org_label.added_by_id.present?
              InteractionInitiator.find_or_create_by_interaction_id_and_person_id(interaction.id, org_label.added_by_id)
            end
            puts "#{i} - OrganizatioanlLabel##{org_label.id} deleted" if org_label.destroy
          end
        end
        sent_label.destroy
        puts "Migration complete! Default label '100% Sent' is now deleted."
      else
        raise "Graduating On Mission InteractionType not found!"
      end
    else
      raise "Sent label was already deleted!"
    end
  end

  def down
  end
end
