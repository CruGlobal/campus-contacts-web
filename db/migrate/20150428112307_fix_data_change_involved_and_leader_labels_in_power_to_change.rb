class Label < ActiveRecord::Base
end
class FixDataChangeInvolvedAndLeaderLabelsInPowerToChange < ActiveRecord::Migration
  def up
    if power_to_change_org = Organization.where(id: APP_CONFIG['power_to_change_org_id']).first
      involved = Label.where(organization_id: 0, i18n: "involved").first
      leader = Label.where(organization_id: 0, i18n: "leader").first
      growing_disciple = Label.where(organization_id: 0, i18n: "growing_disciple").first
      ministering_disciple = Label.where(organization_id: 0, i18n: "ministering_disciple").first
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
      raise "Cannot find Power to Change organization." unless Rails.env.test?
    end
  end

  def down
  end
end
