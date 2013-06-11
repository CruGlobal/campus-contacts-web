class Apic
  API_ALLOWABLE_FIELDS = {
    v1: {
      people: ["first_name", "last_name", "name", "id", "location", "birthday", "locale", "gender", "interactions", "interests", "education", "fb_id", "picture", "status", "request_org_id", "assignment", "organization_membership", "labels", "organizational_permissions", "phone_number", "email_address"],
      school: [""],
      friends: ["uid", "name", "provider"],
      contacts: ["all"],
      contact_assignments: ["all"]
    },
    v2: {
      people: ["first_name", "last_name", "name", "id", "location", "birthday", "locale", "gender", "interactions", "interests", "education", "fb_id", "picture", "status", "request_org_id", "assignment", "organization_membership", "organizational_permissions", "phone_number", "email_address"],
      school: [""],
      friends: ["uid", "name", "provider"],
      contacts: ["all"],
      contact_assignments: ["all"]
    }
   }
  STD_VERSION = 2
end