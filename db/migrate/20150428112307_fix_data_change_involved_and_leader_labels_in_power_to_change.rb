class Label < ActiveRecord::Base
end
class FixDataChangeInvolvedAndLeaderLabelsInPowerToChange < ActiveRecord::Migration
  def up
    if power_to_change_org = Organization.find_by_id(ENV.fetch('POWER_TO_CHANGE_ORG_ID'))
      involved = Label.find_by_organization_id_and_i18n(0, "involved")
      leader = Label.find_by_organization_id_and_i18n(0, "leader")
      growing_disciple = Label.find_by_organization_id_and_i18n(0, "growing_disciple")
      ministering_disciple = Label.find_by_organization_id_and_i18n(0, "ministering_disciple")
      if involved.nil?
        raise "Cannot find Involved label." unless Rails.env.test?
      elsif leader.nil?
        raise "Cannot find Leader label." unless Rails.env.test?
      elsif growing_disciple.nil?
        raise "Cannot find Growing Disciple label." unless Rails.env.test?
      elsif ministering_disciple.nil?
        raise "Cannot find Ministering Disciple label." unless Rails.env.test?
      else
        org_labels = OrganizationalLabel.where("
          (label_id = ? OR label_id = ?) AND organization_id IN (?)",
                                               involved.id,
                                               leader.id,
                                               power_to_change_org.self_and_children.collect(&:id)
                                              )
        if org_labels.present?
          org_labels.each do |org_label|
            if org_label.label_id == involved.id
              org_label.update_attributes(label_id: growing_disciple.id)
            elsif org_label.label_id == leader.id
              org_label.update_attributes(label_id: ministering_disciple.id)
            end
          end
        end
      end
    else
      puts "Cannot find Power to Change organization." unless Rails.env.test?
    end
  end

  def down
  end
end
