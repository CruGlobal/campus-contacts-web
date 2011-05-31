require 'enumerations.rb'

class Apic < Enumerations
  self.add_item(
    :API_ALLOWABLE_FIELDS, {
      :user => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","friends","fb_id","picture"],
      :school => [""],
      :friends => ["id", "name"],
      
    })
    
  self.add_item(
    :SCOPE_REQUIRED, { 
      :user => {
        "all" => ["userinfo"],
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
        },
      :friends => {
        "all" => ["userinfo"],
        "id" =>  ["userinfo"],
        "name" => ["userinfo"]
      }
    })
end
# 
# class Apic 
#    API_ALLOWABLE_FIELDS = {
#      :user => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","friends","fb_id","picture"],
#      :school => [""],
#      :friends => ["id", "name"]
#    }
#    
#     SCOPE_REQUIRED = { 
#      :user => {
#        "all" => ["userinfo"],
#        "first_name" => ["userinfo"],
#        "last_name" => ["userinfo"], 
#        "name" => ["userinfo"], 
#        "id" => ["userinfo"], 
#        "location" => ["userinfo"], 
#        "birthday" => ["userinfo"],
#        "locale" => ["userinfo"], 
#        "gender" => ["userinfo"], 
#        "interests" => ["userinfo"], 
#        "friends" => ["userinfo"], 
#        "fb_id" => ["userinfo"], 
#        "picture" => ["userinfo"]
#        },
#      :friends => {
#        "all" => ["userinfo"],
#        "id" =>  ["userinfo"],
#        "name" => ["userinfo"]
#      }
#    }
# end