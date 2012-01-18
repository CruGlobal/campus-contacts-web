class CreatePersonPhotos < ActiveRecord::Migration
  def change
    create_table :person_photos do |t|
      t.references :person
      t.has_attached_file :image
      
      t.timestamps
    end
  end
end
