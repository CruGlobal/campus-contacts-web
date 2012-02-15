class PersonPhoto < ActiveRecord::Base
  belongs_to :ministry_person, class_name: 'Person'
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                path: "#{Rails.root}/public/uploads/person/:attachment/:id/:style/:filename",
                url: "uploads/person/:attachment/:id/:style/:filename"
  
end
