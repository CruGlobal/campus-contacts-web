class CreateLabels < ActiveRecord::Migration
  def up
    create_table :labels do |t|
      t.integer :organization_id
      t.string :name
      t.string :i18n

      t.timestamps
    end

    if Label.all.empty?
      Label.create(name: 'Involved', i18n: 'involved', organization_id: 0)
      Label.create(name: 'Engaged Disciple', i18n: 'engaged_disciple', organization_id: 0)
      Label.create(name: 'Leader', i18n: 'leader', organization_id: 0)
    end
  end

  def down
    drop_table :labels
  end
end
