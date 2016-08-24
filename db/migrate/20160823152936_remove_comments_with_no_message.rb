class RemoveCommentsWithNoMessage < ActiveRecord::Migration
  def change
    Interaction.where(interaction_type_id: 1, comment: ['', nil]).delete_all
  end
end
