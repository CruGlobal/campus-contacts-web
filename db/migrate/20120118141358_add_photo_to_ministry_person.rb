class AddPhotoToMinistryPerson < ActiveRecord::Migration
  def self.up
    change_table :ministry_person do |t|
      t.has_attached_file :photo
    end
  end

  def self.down
    drop_attached_file :ministry_person, :photo
  end
end
