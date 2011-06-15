class Apic 
  API_ALLOWABLE_FIELDS = {
    :v1 => {
      :people => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","education","fb_id","picture"],
      :school => [""],
      :friends => ["uid", "name", "provider"],
      :contacts => ["all"],
      :contact_assignments => ["all"]
    }
   }
  STD_VERSION = 1
   
  SCOPE_REQUIRED = {
    :people => {
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
      "education" => ["userinfo"], 
      "fb_id" => ["userinfo"], 
      "picture" => ["userinfo"]
      },
    :friends => {
     "all" => ["userinfo"],
     "uid" =>  ["userinfo"],
     "name" => ["userinfo"],
     "provider" => ["userinfo"]
     },
     :contacts => {
       "all" => ["contacts"]
     }  ,
     :contact_assignments => {
       "all" => ["assignments"]
    }
   }
end