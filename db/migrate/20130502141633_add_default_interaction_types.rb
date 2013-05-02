class InteractionType < ActiveRecord::Base
end
class AddDefaultInteractionTypes < ActiveRecord::Migration
  def up
    InteractionType.create(organization_id: 0, name: "Comment Only", i18n: "comment")
    InteractionType.create(organization_id: 0, name: "Spiritual Conversation", i18n: "spiritual_conversation")
    InteractionType.create(organization_id: 0, name: "Gospel Presentation", i18n: "gospel_presentation")
    InteractionType.create(organization_id: 0, name: "Prayed to Receive Christ", i18n: "prayed_to_receive_christ")
    InteractionType.create(organization_id: 0, name: "Holy Spirit Presentation", i18n: "holy_spirit_presentation")
    InteractionType.create(organization_id: 0, name: "Graduating on Mission", i18n: "graduating_on_mission")
    InteractionType.create(organization_id: 0, name: "Faculty on Mission", i18n: "faculty_on_mission")
  end

  def down
    defaults = InteractionType.where(organization_id: 0)
    defaults.where(i18n: "comment").try(:first).try(:destroy)
    defaults.where(i18n: "spiritual_conversation").try(:first).try(:destroy)
    defaults.where(i18n: "gospel_presentation").try(:first).try(:destroy)
    defaults.where(i18n: "prayed_to_receive_christ").try(:first).try(:destroy)
    defaults.where(i18n: "holy_spirit_presentation").try(:first).try(:destroy)
    defaults.where(i18n: "graduating_on_mission").try(:first).try(:destroy)
    defaults.where(i18n: "faculty_on_mission").try(:first).try(:destroy)
  end
end
