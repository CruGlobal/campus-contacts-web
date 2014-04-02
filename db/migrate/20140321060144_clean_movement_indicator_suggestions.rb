class CleanMovementIndicatorSuggestions < ActiveRecord::Migration
  def up
    puts "Cleaning duplicate MovementIndicatorSuggestions"
    puts "---"

    # Select duplicates
    duplicates = MovementIndicatorSuggestion.select("organization_id, label_id, person_id, reason, COUNT(id) as quantity").where(accepted: nil).group(:organization_id, :person_id, :label_id, :reason).having('quantity > 1')

    if duplicates.present?

      duplicates.each do |dup|
        # Find similar records
        similar = MovementIndicatorSuggestion.where(
          organization_id: dup.organization_id,
          person_id: dup.person_id,
          label_id: dup.label_id,
          reason: dup.reason
        )

        puts "Found #{similar.collect(&:id).inspect} similar records!"

        # Select except the first element
        similar = similar.drop(1)

        puts "Deleting #{similar.collect(&:id).inspect} duplicate records!"

        # Delete duplicates
        MovementIndicatorSuggestion.where(id: similar.collect(&:id)).delete_all
        puts "---"
      end
      puts "Cleaning Complete!"
    else
      puts "No Duplicate Records!"
    end
  end

  def down
  end
end
