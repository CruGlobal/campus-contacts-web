class Label < ActiveRecord::Base
end
class AddDefaultSeekerLabel < ActiveRecord::Migration
  def up
    Label.create(organization_id: 0, name: 'Seeker', i18n: 'seeker')
  end

  def down
    seeker_label = Label.find_by_i18n('seeker')
    seeker_label.destroy if seeker_label.present?
  end
end
