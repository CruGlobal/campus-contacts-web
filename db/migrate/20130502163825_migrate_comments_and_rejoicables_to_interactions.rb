class FollowupComment < ActiveRecord::Base
end
class Rejoicable < ActiveRecord::Base
end
class Interaction < ActiveRecord::Base
end
class InteractionType < ActiveRecord::Base
end
class InteractionInitiator < ActiveRecord::Base
end
class MigrateCommentsAndRejoicablesToInteractions < ActiveRecord::Migration
  def up
    comment_interaction_type = InteractionType.find_by_i18n("comment")
    FollowupComment.limit(100).each do |comment|
      interaction = Interaction.new(
        interaction_type_id: comment_interaction_type.id,
        receiver_id: comment.contact_id,
        created_by_id: comment.commenter_id,
        organization_id: comment.organization_id,
        comment: comment.comment,
        privacy_setting: "everyone",
        timestamp: comment.created_at,
        deleted_at: comment.deleted_at,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      )
      if interaction.save
        InteractionInitiator.create(interaction_id: interaction.id, person_id: comment.commenter_id)
        any_rejoicables = Rejoicable.where("(deleted_at IS NULL OR deleted_at IS NOT NULL) AND what IS NOT NULL")
        any_rejoicables.where("followup_comment_id = ?", comment.id).each do |rejoicable|
          if rejoicable.what.present?
            interaction_i18n = rejoicable.what == "prayed_to_receive" ? "prayed_to_receive_christ" : rejoicable.what
            interaction_type = InteractionType.find_by_i18n(interaction_i18n)

            interaction = Interaction.create(
              interaction_type_id: interaction_type.id,
              receiver_id: rejoicable.person_id,
              created_by_id: rejoicable.created_by_id,
              organization_id: rejoicable.organization_id,
              comment: comment.comment,
              privacy_setting: "everyone",
              timestamp: rejoicable.created_at,
              deleted_at: rejoicable.deleted_at,
              created_at: rejoicable.created_at,
              updated_at: rejoicable.updated_at
            )
            InteractionInitiator.create(interaction_id: interaction.id, person_id: rejoicable.created_by_id)
          end
        end
      end
    end
  end

  def down
  end
end
