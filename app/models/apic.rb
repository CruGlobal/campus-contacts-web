class Apic 
  API_ALLOWABLE_FIELDS = {
    :v1 => {
      :people => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","education","fb_id","picture", "status", "request_org_id", "assignment", "organization_membership","phone_number","email_address"],
      :school => [""],
      :friends => ["uid", "name", "provider"],
      :contacts => ["all"],
      :contact_assignments => ["all"]
    }
   }
  STD_VERSION = 1
end