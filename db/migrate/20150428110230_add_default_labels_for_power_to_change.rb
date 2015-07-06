class Label < ActiveRecord::Base
end
class AddDefaultLabelsForPowerToChange < ActiveRecord::Migration
  def change
    new_default_labels = {
      "knows_and_trusts_christian" => "Knows and trusts a Christian",
      "became_curious" => "Became curious",
      "became_open_to_change" => "Became open to change",
      "seeking_god" => "Seeking God",
      "made_decision" => "Made a decision",
      "growing_disciple" => "Growing disciple",
      "ministering_disciple" => "Ministering disciple",
      "multiplying_disciple" => "Multiplying disciple"
    }
    new_default_labels.each do |key, val|
      Label.where(name: val, i18n: key, organization_id: 0).first_or_create
    end
  end
end
