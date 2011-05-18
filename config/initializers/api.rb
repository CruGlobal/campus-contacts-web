require 'enumerations.rb'

class Apic < Enumerations
  self.add_item(:API_ALLOWABLE, {
    #still not sure whether to have nested hashes or just use hash of nested arrays
    #if I did a nested hash I would do :user => {"first_name" => :first_name, "last_name" => :last_name, "name" => :name}
    :user => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","friends","fb_id","picture"],
    :school => [""]
    })
    
  self.add_item(:SCOPE_REQUIRED, {
      "first_name" => ["userinfo"],
      "last_name" => ["userinfo"], 
      "name" => ["userinfo"], 
      "id" => ["userinfo"], 
      "location" => ["userinfo"], 
      "birthday" => ["userinfo"],
      "locale" => ["userinfo"], 
      "gender" => ["userinfo"], 
      "interests" => ["userinfo"], 
      "friends" => ["userinfo"], 
      "fb_id" => ["userinfo"], 
      "picture" => ["userinfo"]
      })
end

#Let's define the fields that we allow to be accessed from the API
# API_ALLOWABLE = {
#   #still not sure whether to have nested hashes or just use hash of nested arrays
#   #if I did a nested hash I would do :user => {"first_name" => :first_name, "last_name" => :last_name, "name" => :name}
#   :user => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","friends","fb_id","picture"],
#   :school => [""]
#   }
#   puts "hi there!"
# SCOPE_REQUIRED = {
#   "first_name" => ["userinfo"],
#   "last_name" => ["userinfo"], 
#   "name" => ["userinfo"], 
#   "id" => ["userinfo"], 
#   "location" => ["userinfo"], 
#   "birthday" => ["userinfo"],
#   "locale" => ["userinfo"], 
#   "gender" => ["userinfo"], 
#   "interests" => ["userinfo"], 
#   "friends" => ["userinfo"], 
#   "fb_id" => ["userinfo"], 
#   "picture" => ["userinfo"]
#   }