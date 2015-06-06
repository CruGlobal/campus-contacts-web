class AddNewInteractionIcons < ActiveRecord::Migration
  def up
    if x = InteractionType.where(name: "Basic Follow-up").first
      x.update_attributes(icon: "flag.png")
    end
    if x = InteractionType.where(name: "Discipleship / Leadership").first
      x.update_attributes(icon: "share.png")
    end
  end

  def down
    if x = InteractionType.where(name: "Basic Follow-up").first
      x.update_attributes(icon: nil)
    end
    if x = InteractionType.where(name: "Discipleship / Leadership").first
      x.update_attributes(icon: nil)
    end
  end
end
