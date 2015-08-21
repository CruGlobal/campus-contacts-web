class DeleteInteractionsWithInvalidInteractionType < ActiveRecord::Migration
  def change
    valid_interaction_type_ids = InteractionType.all.collect(&:id)
    Interaction.where("interaction_type_id NOT IN (?)", valid_interaction_type_ids).update_all(deleted_at: Time.now)
  end
end
