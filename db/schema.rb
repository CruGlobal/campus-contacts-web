# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121102181250) do

  create_table "access_grants", :force => true do |t|
    t.string   "code"
    t.integer  "identity"
    t.string   "client_id"
    t.string   "redirect_uri"
    t.string   "scope",        :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "granted_at"
    t.datetime "expires_at"
    t.string   "access_token"
    t.datetime "revoked"
  end

  add_index "access_grants", ["client_id"], :name => "index_access_grants_on_client_id"
  add_index "access_grants", ["code"], :name => "index_access_grants_on_code", :unique => true

  create_table "access_tokens", :force => true do |t|
    t.string   "code"
    t.integer  "identity"
    t.string   "client_id"
    t.string   "scope",       :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expires_at"
    t.datetime "revoked"
    t.datetime "last_access"
    t.datetime "prev_access"
  end

  add_index "access_tokens", ["client_id"], :name => "index_access_tokens_on_client_id"
  add_index "access_tokens", ["code"], :name => "index_access_tokens_on_code", :unique => true
  add_index "access_tokens", ["identity"], :name => "index_access_tokens_on_identity"

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "activities", :force => true do |t|
    t.integer  "target_area_id"
    t.integer  "organization_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "status",          :default => "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["target_area_id", "organization_id"], :name => "index_activities_on_target_area_id_and_organization_id", :unique => true

  create_table "addresses", :force => true do |t|
<<<<<<< Updated upstream
    t.string   "address1"
    t.string   "address2"
    t.string   "address3",     :limit => 55
    t.string   "address4",     :limit => 55
    t.string   "city",         :limit => 50
    t.string   "state",        :limit => 50
    t.string   "zip",          :limit => 15
    t.string   "country",      :limit => 64
    t.string   "address_type", :limit => 20
=======
    t.string   "deprecated_startDate", :limit => 25
    t.string   "deprecated_endDate",   :limit => 25
    t.string   "address1",             :limit => 55
    t.string   "address2",             :limit => 55
    t.string   "address3",             :limit => 55
    t.string   "address4",             :limit => 55
    t.string   "city",                 :limit => 50
    t.string   "state",                :limit => 50
    t.string   "zip",                  :limit => 15
    t.string   "country",              :limit => 64
    t.string   "address_type",         :limit => 20
>>>>>>> Stashed changes
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "dorm"
    t.string   "room"
<<<<<<< Updated upstream
=======
  end

  add_index "addresses", ["address_type", "person_id"], :name => "unique_person_addressType", :unique => true
  add_index "addresses", ["address_type"], :name => "index_ministry_newAddress_on_addressType"
  add_index "addresses", ["person_id"], :name => "FKAB431D54B5C286E8"
  add_index "addresses", ["person_id"], :name => "fk_PersonID"

  create_table "am_friends_people_deprecated", :id => false, :force => true do |t|
    t.integer "friend_id", :null => false
    t.integer "person_id", :null => false
  end

  create_table "am_group_links_deprecated", :force => true do |t|
    t.string  "api",         :limit => 50,         :null => false
    t.string  "url",         :limit => 500,        :null => false
    t.string  "title",       :limit => 500
    t.text    "description", :limit => 2147483647
    t.integer "group_id",                          :null => false
  end

  add_index "am_group_links_deprecated", ["group_id"], :name => "group_id"

  create_table "am_group_messages_deprecated", :force => true do |t|
    t.string   "subject",    :limit => 500
    t.text     "body",       :limit => 2147483647
    t.datetime "created_on",                       :null => false
    t.integer  "group_id",                         :null => false
    t.integer  "person_id",                        :null => false
  end

  add_index "am_group_messages_deprecated", ["group_id"], :name => "group_id"
  add_index "am_group_messages_deprecated", ["person_id"], :name => "person_id"

  create_table "am_groups_deprecated", :force => true do |t|
    t.string  "name",                                :null => false
    t.string  "url_safe_name",                       :null => false
    t.text    "description",   :limit => 2147483647
    t.string  "group_type",    :limit => 50
    t.integer "lookup_id"
  end

  add_index "am_groups_deprecated", ["lookup_id"], :name => "lookup_id"

  create_table "am_groups_people_deprecated", :id => false, :force => true do |t|
    t.integer  "person_id",  :null => false
    t.integer  "group_id",   :null => false
    t.datetime "created_on"
  end

  create_table "am_personal_links_deprecated", :force => true do |t|
    t.string  "api",         :limit => 50,         :null => false
    t.string  "url",         :limit => 500,        :null => false
    t.string  "title",       :limit => 500
    t.text    "description", :limit => 2147483647
    t.integer "person_id",                         :null => false
>>>>>>> Stashed changes
  end

  add_index "addresses", ["address_type", "person_id"], :name => "unique_person_addressType", :unique => true
  add_index "addresses", ["address_type"], :name => "index_ministry_newAddress_on_addressType"
  add_index "addresses", ["person_id"], :name => "fk_PersonID"

  create_table "answer_sheets", :force => true do |t|
    t.datetime "created_at",   :null => false
    t.datetime "completed_at"
    t.integer  "person_id"
    t.datetime "updated_at"
    t.integer  "survey_id"
  end

  add_index "answer_sheets", ["person_id", "survey_id"], :name => "person_id_survey_id"

  create_table "answers", :force => true do |t|
    t.integer  "answer_sheet_id",         :null => false
    t.integer  "question_id",             :null => false
    t.text     "value"
    t.string   "short_value"
    t.integer  "attachment_file_size"
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["answer_sheet_id"], :name => "index_ma_answers_on_answer_sheet_id"
  add_index "answers", ["question_id"], :name => "index_ma_answers_on_question_id"
  add_index "answers", ["short_value"], :name => "index_ma_answers_on_short_value"

  create_table "api_logs", :force => true do |t|
    t.string   "platform"
    t.string   "action"
    t.integer  "identity"
    t.integer  "organization_id"
    t.text     "error"
    t.text     "url"
    t.string   "access_token"
    t.string   "remote_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "platform_release"
    t.string   "platform_product"
    t.string   "app"
  end

  create_table "auth_requests", :force => true do |t|
    t.string   "code"
    t.string   "client_id"
    t.string   "scope",         :default => ""
    t.string   "redirect_uri"
    t.string   "state"
    t.string   "response_type"
    t.string   "grant_code"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "authorized_at"
    t.datetime "revoked"
  end

  add_index "auth_requests", ["client_id"], :name => "index_auth_requests_on_client_id"
  add_index "auth_requests", ["code"], :name => "index_auth_requests_on_code"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "authentications", ["uid", "provider"], :name => "uid_provider", :unique => true

  create_table "clients", :force => true do |t|
    t.string   "code"
    t.string   "secret"
    t.string   "display_name"
    t.string   "link"
    t.string   "image_url"
    t.string   "redirect_uri"
    t.string   "scope",           :default => ""
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "revoked"
    t.integer  "organization_id"
  end

  add_index "clients", ["code"], :name => "index_clients_on_code", :unique => true
  add_index "clients", ["display_name"], :name => "index_clients_on_display_name", :unique => true
  add_index "clients", ["link"], :name => "index_clients_on_link", :unique => true
  add_index "clients", ["organization_id"], :name => "index_clients_on_organization_id"

  create_table "contact_assignments", :force => true do |t|
    t.integer  "assigned_to_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "contact_assignments", ["assigned_to_id", "organization_id"], :name => "index_contact_assignments_on_assigned_to_id_and_organization_id"
  add_index "contact_assignments", ["organization_id"], :name => "index_contact_assignments_on_organization_id"
  add_index "contact_assignments", ["person_id", "organization_id"], :name => "index_contact_assignments_on_person_id_and_organization_id", :unique => true

  create_table "dashboard_posts", :force => true do |t|
    t.string   "title",      :default => ""
    t.text     "context"
    t.string   "video",      :default => ""
    t.boolean  "visible",    :default => true
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "education_histories", :force => true do |t|
    t.integer  "person_id"
    t.string   "type"
    t.string   "concentration_id1"
    t.string   "concentration_name1"
    t.string   "concentration_id2"
    t.string   "concentration_name2"
    t.string   "concentration_id3"
    t.string   "concentration_name3"
    t.string   "year_id"
    t.string   "year_name"
    t.string   "degree_id"
    t.string   "degree_name"
    t.string   "school_id"
    t.string   "school_name"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school_type"
  end

  create_table "elements", :force => true do |t|
    t.string   "kind",                      :limit => 40, :default => "",    :null => false
    t.string   "style",                     :limit => 40
    t.text     "label"
    t.text     "content"
    t.boolean  "required"
    t.string   "slug",                      :limit => 36
    t.integer  "position"
    t.string   "object_name"
    t.string   "attribute_name"
    t.string   "source"
    t.string   "value_xpath"
    t.string   "text_xpath"
    t.integer  "question_grid_id"
    t.string   "cols"
    t.boolean  "is_confidential"
    t.string   "total_cols"
    t.string   "css_id"
    t.string   "css_class"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "related_question_sheet_id"
    t.integer  "conditional_id"
    t.text     "tooltip"
    t.boolean  "hide_label",                              :default => false
    t.boolean  "hide_option_labels",                      :default => false
    t.integer  "max_length"
    t.boolean  "web_only",                                :default => false
    t.string   "trigger_words"
    t.string   "notify_via"
    t.boolean  "hidden",                                  :default => false, :null => false
    t.integer  "crs_question_id"
  end

  add_index "elements", ["conditional_id"], :name => "index_ma_elements_on_conditional_id"
  add_index "elements", ["crs_question_id"], :name => "index_elements_on_crs_question_id"
  add_index "elements", ["position"], :name => "index_ma_elements_on_question_sheet_id_and_position_and_page_id"
  add_index "elements", ["question_grid_id"], :name => "index_ma_elements_on_question_grid_id"
  add_index "elements", ["slug"], :name => "index_ma_elements_on_slug"

  create_table "email_addresses", :force => true do |t|
    t.string   "email"
    t.integer  "person_id"
    t.boolean  "primary",    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_addresses", ["email"], :name => "email"
  add_index "email_addresses", ["person_id"], :name => "person_id"

  create_table "followup_comments", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "commenter_id"
    t.text     "comment"
    t.string   "status"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "followup_comments", ["organization_id", "contact_id"], :name => "comment_organization_id_contact_id"

  create_table "friends_deprecated", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.string   "provider"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends_deprecated", ["person_id", "uid"], :name => "person_uid", :unique => true

  create_table "group_labelings", :force => true do |t|
    t.integer  "group_id"
    t.integer  "group_label_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_labelings", ["group_id", "group_label_id"], :name => "index_mh_group_labelings_on_group_id_and_group_label_id", :unique => true
  add_index "group_labelings", ["group_label_id"], :name => "index_mh_group_labelings_on_group_label_id"

  create_table "group_labels", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.string   "ancestry"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_labelings_count", :default => 0
  end

  add_index "group_labels", ["organization_id"], :name => "index_mh_group_labels_on_organization_id"

  create_table "group_memberships", :force => true do |t|
    t.integer  "group_id"
    t.integer  "person_id"
    t.string   "role",       :default => "member"
    t.boolean  "requested",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["group_id"], :name => "index_group_memberships_on_group_id"
  add_index "group_memberships", ["person_id"], :name => "index_group_memberships_on_person_id"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "location"
    t.string   "meets"
    t.integer  "meeting_day"
    t.integer  "start_time"
    t.integer  "end_time"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "list_publicly",         :default => true
    t.boolean  "approve_join_requests", :default => true
  end

  create_table "imports", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.text     "headers"
    t.text     "header_mappings"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "imports", ["organization_id"], :name => "index_mh_imports_on_organization_id"
  add_index "imports", ["user_id", "organization_id"], :name => "user_org"

  create_table "interests", :force => true do |t|
    t.string   "name"
    t.string   "interest_id"
    t.string   "provider"
    t.string   "category"
    t.integer  "person_id"
    t.datetime "interest_created_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "location_id"
    t.string   "name"
    t.string   "provider"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "merge_audits", :force => true do |t|
    t.integer  "mergeable_id"
    t.string   "mergeable_type"
    t.integer  "merge_looser_id"
    t.string   "merge_looser_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merge_audits", ["merge_looser_id", "merge_looser_type"], :name => "merge_looser"
  add_index "merge_audits", ["mergeable_id", "mergeable_type"], :name => "mergeable"

  create_table "new_people", :force => true do |t|
    t.integer  "person_id"
    t.integer  "organization_id"
    t.boolean  "notified",        :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "organization_memberships", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "person_id"
    t.boolean  "primary",         :default => false
    t.boolean  "validated",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
  end

  add_index "organization_memberships", ["organization_id", "person_id"], :name => "index_organization_memberships_on_organization_id_and_person_id", :unique => true
  add_index "organization_memberships", ["person_id"], :name => "person_id"

  create_table "organizational_roles", :force => true do |t|
    t.integer  "person_id"
    t.integer  "role_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "deleted",         :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "followup_status"
    t.integer  "added_by_id"
    t.datetime "archive_date"
  end

  add_index "organizational_roles", ["organization_id", "role_id", "followup_status"], :name => "role_org_status"
  add_index "organizational_roles", ["person_id", "organization_id", "role_id"], :name => "person_role_org", :unique => true

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.boolean  "requires_validation", :default => false
    t.string   "validation_method"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.string   "terminology"
    t.integer  "importable_id"
    t.string   "importable_type"
    t.boolean  "show_sub_orgs",       :default => false,    :null => false
    t.string   "status",              :default => "active", :null => false
    t.text     "settings"
    t.integer  "conference_id"
  end

  add_index "organizations", ["ancestry"], :name => "index_organizations_on_ancestry"
  add_index "organizations", ["conference_id"], :name => "index_organizations_on_conference_id"
  add_index "organizations", ["importable_type", "importable_id"], :name => "index_organizations_on_importable_type_and_importable_id", :unique => true
  add_index "organizations", ["name"], :name => "index_organizations_on_name"

  create_table "people", :force => true do |t|
    t.string   "accountNo",                     :limit => 11
    t.string   "last_name",                     :limit => 50
    t.string   "first_name",                    :limit => 50
    t.string   "middle_name",                   :limit => 50
    t.string   "gender",                        :limit => 1
    t.string   "year_in_school",                :limit => 20
    t.string   "major",                         :limit => 70
    t.string   "minor",                         :limit => 70
    t.string   "campus",                        :limit => 70
    t.string   "greek_affiliation",             :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.date     "birth_date"
    t.date     "date_became_christian"
    t.date     "graduation_date"
    t.string   "level_of_school"
    t.string   "staff_notes"
    t.integer  "primary_campus_involvement_id"
    t.integer  "mentor_id"
    t.integer  "fb_uid",                        :limit => 8
    t.datetime "date_attributes_updated"
    t.text     "organization_tree_cache"
    t.text     "org_ids_cache"
    t.integer  "crs_profile_id"
    t.integer  "sp_person_id"
    t.integer  "si_person_id"
    t.integer  "pr_person_id"
  end

  add_index "people", ["accountNo"], :name => "accountNo_ministry_Person"
  add_index "people", ["crs_profile_id"], :name => "index_people_on_crs_profile_id"
  add_index "people", ["fb_uid"], :name => "index_ministry_person_on_fb_uid"
  add_index "people", ["first_name", "last_name"], :name => "firstName_lastName"
  add_index "people", ["last_name"], :name => "lastname_ministry_Person"
  add_index "people", ["org_ids_cache"], :name => "index_ministry_person_on_org_ids_cache", :length => {"org_ids_cache"=>255}
  add_index "people", ["pr_person_id"], :name => "index_people_on_pr_person_id"
  add_index "people", ["si_person_id"], :name => "index_people_on_si_person_id"
  add_index "people", ["sp_person_id"], :name => "index_people_on_sp_person_id"
  add_index "people", ["user_id"], :name => "fk_ssmUserId"

  create_table "person_photos", :force => true do |t|
    t.integer  "person_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "person_transfers", :force => true do |t|
    t.integer  "person_id"
    t.integer  "old_organization_id"
    t.integer  "new_organization_id"
    t.boolean  "copy",                :default => false
    t.boolean  "notified",            :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "transferred_by_id"
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.string   "extension"
    t.integer  "person_id"
    t.string   "location",         :default => "mobile"
    t.boolean  "primary",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "txt_to_email"
    t.integer  "carrier_id"
    t.datetime "email_updated_at"
  end

  add_index "phone_numbers", ["carrier_id"], :name => "index_phone_numbers_on_carrier_id"
  add_index "phone_numbers", ["number"], :name => "index_phone_numbers_on_number"
  add_index "phone_numbers", ["person_id", "number"], :name => "index_phone_numbers_on_person_id_and_number"

  create_table "profile_pictures", :force => true do |t|
    t.integer "person_id"
    t.integer "parent_id"
    t.integer "size"
    t.integer "height"
    t.integer "width"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.date    "uploaded_date"
  end

  add_index "profile_pictures", ["person_id"], :name => "index_profile_pictures_on_person_id"

  create_table "question_leaders", :force => true do |t|
    t.integer  "person_id"
    t.integer  "element_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_rules", :force => true do |t|
    t.integer  "survey_element_id"
    t.integer  "rule_id"
    t.string   "trigger_keywords"
    t.string   "extra_parameters"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "question_sheets", :force => true do |t|
    t.string  "label",              :limit => 60, :default => "",    :null => false
    t.boolean "archived",                         :default => false
    t.integer "questionnable_id"
    t.string  "questionnable_type"
  end

  add_index "question_sheets", ["questionnable_id", "questionnable_type"], :name => "questionnable"

  create_table "rails_admin_histories", :force => true do |t|
    t.string   "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_histories_on_item_and_table_and_month_and_year"

  create_table "received_sms", :force => true do |t|
    t.string   "phone_number"
    t.string   "carrier"
    t.string   "shortcode"
    t.string   "message"
    t.string   "country"
    t.integer  "person_id"
    t.datetime "received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sms_keyword_id"
    t.integer  "sms_session_id"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "twilio_sid"
  end

  add_index "received_sms", ["person_id"], :name => "person_id"
  add_index "received_sms", ["phone_number", "message", "received_at"], :name => "index_received_sms_on_phone_number_and_message_and_received_at", :unique => true
  add_index "received_sms", ["twilio_sid"], :name => "index_received_sms_on_twilio_sid", :unique => true

  create_table "rejoicables", :force => true do |t|
    t.integer  "person_id"
    t.integer  "created_by_id"
    t.integer  "organization_id"
    t.integer  "followup_comment_id"
    t.string   "what",                :limit => 22
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "roles", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "i18n"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rules", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "action_method"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "limit_per_survey", :default => 0
    t.string   "rule_code"
  end

  create_table "saved_contact_searches", :force => true do |t|
    t.string   "name"
    t.string   "full_path",  :limit => 4000
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_contact_searches", ["user_id"], :name => "index_saved_contact_searches_on_user_id"

  create_table "school_years", :force => true do |t|
    t.string   "name"
    t.string   "level"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sent_sms", :force => true do |t|
    t.text     "message"
    t.string   "recipient"
    t.text     "reports"
    t.string   "moonshado_claimcheck"
    t.string   "sent_via"
    t.integer  "received_sms_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twilio_sid"
    t.string   "twilio_uri"
    t.string   "separator"
    t.integer  "question_id"
  end

  add_index "sent_sms", ["twilio_sid"], :name => "index_sent_sms_on_twilio_sid", :unique => true

  create_table "sms_carriers", :force => true do |t|
    t.string   "name"
    t.string   "moonshado_name"
    t.string   "email"
    t.integer  "recieved",       :default => 0
    t.integer  "sent_emails",    :default => 0
    t.integer  "bounced_emails", :default => 0
    t.integer  "sent_sms",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cloudvox_name"
    t.string   "data247_name"
  end

  create_table "sms_keywords", :force => true do |t|
    t.string   "keyword"
    t.integer  "event_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chartfield"
    t.integer  "user_id"
    t.text     "explanation"
    t.string   "state"
    t.string   "initial_response",               :limit => 145
    t.text     "post_survey_message_deprecated"
    t.string   "event_type"
    t.string   "gateway",                                       :default => "twilio", :null => false
    t.integer  "survey_id"
  end

  add_index "sms_keywords", ["organization_id"], :name => "organization_id"
  add_index "sms_keywords", ["survey_id"], :name => "index_sms_keywords_on_survey_id"
  add_index "sms_keywords", ["user_id"], :name => "user_id"

  create_table "sms_sessions", :force => true do |t|
    t.string   "phone_number"
    t.integer  "person_id"
    t.integer  "sms_keyword_id"
    t.boolean  "interactive",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ended",          :default => false, :null => false
  end

  add_index "sms_sessions", ["phone_number", "updated_at"], :name => "session"

  create_table "super_admins", :force => true do |t|
    t.integer  "user_id"
    t.string   "site"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "super_admins", ["user_id"], :name => "index_super_admins_on_user_id"

  create_table "survey_elements", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "element_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",     :default => false
    t.boolean  "archived",   :default => false
  end

  add_index "survey_elements", ["survey_id", "element_id"], :name => "survey_id_element_id"

  create_table "surveys", :force => true do |t|
    t.string   "title",                  :limit => 100, :default => "",       :null => false
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "post_survey_message"
    t.string   "terminology",                           :default => "Survey"
    t.integer  "login_option",                          :default => 0
    t.boolean  "is_frozen"
    t.text     "login_paragraph"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "css_file_file_name"
    t.string   "css_file_content_type"
    t.integer  "css_file_file_size"
    t.datetime "css_file_updated_at"
    t.text     "css"
    t.string   "background_color"
    t.string   "text_color"
    t.integer  "crs_registrant_type_id"
  end

  add_index "surveys", ["crs_registrant_type_id"], :name => "index_surveys_on_crs_registrant_type_id"
  add_index "surveys", ["organization_id"], :name => "index_mh_surveys_on_organization_id"

  create_table "users", :force => true do |t|
    t.string   "username",                  :limit => 200,                :null => false
    t.string   "password",                  :limit => 80
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "developer"
    t.string   "email"
    t.string   "encrypted_password"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            :default => 0
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sign_in_at"
    t.string   "locale"
    t.text     "settings"
  end

  add_index "users", ["email"], :name => "index_simplesecuritymanager_user_on_email", :unique => true
  add_index "users", ["username"], :name => "CK_simplesecuritymanager_user_username", :unique => true

  add_foreign_key "answers", "elements", :name => "answers_ibfk_1", :column => "question_id"

  add_foreign_key "organization_memberships", "organizations", :name => "organization_memberships_ibfk_2", :dependent => :delete

  add_foreign_key "organizational_roles", "organizations", :name => "organizational_roles_ibfk_1", :dependent => :delete

  add_foreign_key "sms_keywords", "organizations", :name => "sms_keywords_ibfk_4", :dependent => :delete
  add_foreign_key "sms_keywords", "surveys", :name => "sms_keywords_ibfk_3", :dependent => :nullify

  add_foreign_key "surveys", "organizations", :name => "surveys_ibfk_1", :dependent => :delete

=======
  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "wsn_sp_answer_deprecated", :primary_key => "answerID", :force => true do |t|
    t.string  "body",                :limit => 1000
    t.integer "fk_QuestionID"
    t.integer "fk_WsnApplicationID"
  end

  add_index "wsn_sp_answer_deprecated", ["fk_QuestionID", "fk_WsnApplicationID"], :name => "fk_WsnApplicationID"

  create_table "wsn_sp_question_deprecated", :primary_key => "questionID", :force => true do |t|
    t.string  "required",          :limit => 1
    t.integer "displayOrder"
    t.integer "fk_WsnProjectID"
    t.integer "fk_QuestionTextID"
  end

  add_index "wsn_sp_question_deprecated", ["fk_QuestionTextID"], :name => "fk_QuestionTextID"
  add_index "wsn_sp_question_deprecated", ["fk_WsnProjectID"], :name => "fk_WsnProjectID"

  create_table "wsn_sp_questiontext_deprecated", :primary_key => "questionTextID", :force => true do |t|
    t.string "body",       :limit => 250
    t.string "answerType", :limit => 50
    t.string "status",     :limit => 50
  end

  create_table "wsn_sp_reference_deprecated", :primary_key => "referenceID", :force => true do |t|
    t.string   "formWorkflowStatus",  :limit => 1
    t.datetime "createDate"
    t.datetime "lastChangedDate"
    t.string   "lastChangedBy",       :limit => 30
    t.boolean  "isFormSubmitted"
    t.datetime "formSubmittedDate"
    t.string   "referenceType",       :limit => 2
    t.string   "title",               :limit => 5
    t.string   "firstName",           :limit => 30
    t.string   "lastName",            :limit => 30
    t.boolean  "isStaff"
    t.string   "staffNumber",         :limit => 16
    t.string   "currentAddress1",     :limit => 50
    t.string   "currentAddress2",     :limit => 50
    t.string   "currentCity",         :limit => 35
    t.string   "currentState",        :limit => 6
    t.string   "currentZip",          :limit => 10
    t.string   "cellPhone",           :limit => 24
    t.string   "homePhone",           :limit => 24
    t.string   "workPhone",           :limit => 24
    t.string   "currentEmail",        :limit => 50
    t.string   "howKnown",            :limit => 64
    t.string   "howLongKnown",        :limit => 64
    t.string   "howWellKnown",        :limit => 64
    t.boolean  "sendMidEval"
    t.integer  "_1a"
    t.integer  "_2a"
    t.integer  "_3a"
    t.integer  "_4a"
    t.integer  "_5a"
    t.integer  "_6a"
    t.integer  "_7a"
    t.integer  "_8a"
    t.integer  "_9a"
    t.integer  "_10a"
    t.integer  "_11a"
    t.integer  "_12a"
    t.integer  "_13a"
    t.integer  "_14a"
    t.integer  "_15a"
    t.integer  "_16a"
    t.integer  "_17a"
    t.integer  "_18a"
    t.integer  "_19a"
    t.integer  "_20a"
    t.integer  "_21a"
    t.text     "_1sa",                :limit => 16777215
    t.text     "_2sa",                :limit => 16777215
    t.text     "_3sa",                :limit => 16777215
    t.text     "_4sa",                :limit => 16777215
    t.text     "_5sa",                :limit => 16777215
    t.text     "_6sa",                :limit => 16777215
    t.string   "_6sb",                :limit => 1
    t.text     "_6sc",                :limit => 16777215
    t.text     "_7sa",                :limit => 16777215
    t.text     "_8sa",                :limit => 16777215
    t.text     "closingRemarks",      :limit => 16777215
    t.integer  "fk_WsnApplicationID"
  end

  add_index "wsn_sp_reference_deprecated", ["fk_WsnApplicationID"], :name => "fk_WsnApplicationID"

  create_table "wsn_sp_wsnapplication_deprecated", :primary_key => "WsnApplicationID", :force => true do |t|
    t.string   "surferID",                      :limit => 64
    t.string   "role",                          :limit => 1
    t.string   "earliestAvailableDate",         :limit => 22
    t.string   "dateMustReturn",                :limit => 22
    t.boolean  "willingForDifferentProject",                          :default => true
    t.boolean  "usCitizen",                                           :default => true
    t.boolean  "isApplicationComplete",                               :default => false
    t.integer  "projectPref1"
    t.integer  "projectPref2"
    t.integer  "projectPref3"
    t.integer  "projectPref4"
    t.integer  "projectPref5"
    t.string   "applAccountNo",                 :limit => 11
    t.float    "supportBalance"
    t.boolean  "insuranceReceived",                                   :default => false
    t.boolean  "waiverReceived",                                      :default => false
    t.boolean  "didGo",                                               :default => false
    t.boolean  "participantEvaluation",                               :default => false
    t.string   "arrivalGatewayCityToLocation",  :limit => 22
    t.string   "locationToGatewayCityFlightNo", :limit => 50
    t.string   "departLocationToGatewayCity",   :limit => 22
    t.string   "passportNo",                    :limit => 25
    t.string   "passportCountry",               :limit => 50
    t.string   "passportIssueDate",             :limit => 22
    t.string   "passportExpirationDate",        :limit => 22
    t.string   "visaCountry",                   :limit => 50
    t.string   "visaNo",                        :limit => 50
    t.string   "visaType",                      :limit => 50
    t.boolean  "visaIsMultipleEntry",                                 :default => false
    t.string   "visaIssueDate",                 :limit => 22
    t.string   "visaExpirationDate",            :limit => 22
    t.string   "dateUpdated",                   :limit => 22
    t.boolean  "isStaff",                                             :default => false
    t.boolean  "prevIsp",                                             :default => false
    t.boolean  "child",                                               :default => false
    t.string   "status",                        :limit => 22
    t.string   "wsnYear",                       :limit => 4
    t.integer  "fk_isMember"
    t.boolean  "participateImpact",                                   :default => false
    t.boolean  "participateDestino",                                  :default => false
    t.boolean  "participateEpic"
    t.datetime "springBreakStart"
    t.datetime "springBreakEnd"
    t.boolean  "isIntern",                                            :default => false
    t.boolean  "_1a",                                                 :default => false
    t.boolean  "_1b",                                                 :default => false
    t.boolean  "_1c",                                                 :default => false
    t.boolean  "_1d",                                                 :default => false
    t.boolean  "_1e",                                                 :default => false
    t.text     "_1f",                           :limit => 2147483647
    t.boolean  "_2a"
    t.text     "_2b",                           :limit => 2147483647
    t.boolean  "_2c"
    t.boolean  "_3a"
    t.boolean  "_3b"
    t.boolean  "_3c"
    t.boolean  "_3d"
    t.boolean  "_3e"
    t.boolean  "_3f"
    t.boolean  "_3g"
    t.text     "_3h",                           :limit => 2147483647
    t.boolean  "_4a"
    t.boolean  "_4b"
    t.boolean  "_4c"
    t.boolean  "_4d"
    t.boolean  "_4e"
    t.boolean  "_4f"
    t.boolean  "_4g"
    t.boolean  "_4h"
    t.text     "_4i",                           :limit => 2147483647
    t.boolean  "_5a"
    t.boolean  "_5b"
    t.boolean  "_5c"
    t.boolean  "_5d"
    t.text     "_5e",                           :limit => 2147483647
    t.boolean  "_5f"
    t.text     "_5g",                           :limit => 2147483647
    t.boolean  "_5h"
    t.text     "_6",                            :limit => 2147483647
    t.text     "_7",                            :limit => 2147483647
    t.text     "_8a",                           :limit => 2147483647
    t.text     "_8b",                           :limit => 2147483647
    t.text     "_9",                            :limit => 2147483647
    t.text     "_10",                           :limit => 2147483647
    t.boolean  "_11a"
    t.text     "_11b",                          :limit => 2147483647
    t.boolean  "_12a"
    t.text     "_12b",                          :limit => 2147483647
    t.boolean  "_13a"
    t.boolean  "_13b"
    t.boolean  "_13c"
    t.text     "_14",                           :limit => 2147483647
    t.boolean  "_15"
    t.integer  "_16"
    t.integer  "_17"
    t.integer  "_18"
    t.boolean  "_19a"
    t.boolean  "_19b"
    t.boolean  "_19c"
    t.boolean  "_19d"
    t.boolean  "_19e"
    t.string   "_19f"
    t.text     "_20a",                          :limit => 2147483647
    t.text     "_20b",                          :limit => 2147483647
    t.text     "_20c",                          :limit => 2147483647
    t.boolean  "_21a"
    t.boolean  "_21b"
    t.boolean  "_21c"
    t.boolean  "_21d"
    t.boolean  "_21e"
    t.boolean  "_21f"
    t.boolean  "_21g"
    t.boolean  "_21h"
    t.text     "_21i",                          :limit => 2147483647
    t.string   "_21j",                          :limit => 1
    t.boolean  "_22a"
    t.text     "_22b",                          :limit => 2147483647
    t.boolean  "_23a"
    t.text     "_23b",                          :limit => 2147483647
    t.boolean  "_24a"
    t.text     "_24b",                          :limit => 2147483647
    t.text     "_25",                           :limit => 2147483647
    t.boolean  "_26a"
    t.text     "_26b",                          :limit => 2147483647
    t.boolean  "_27a"
    t.text     "_27b",                          :limit => 2147483647
    t.boolean  "_28a"
    t.text     "_28b",                          :limit => 2147483647
    t.boolean  "_29a"
    t.text     "_29b",                          :limit => 2147483647
    t.boolean  "_29c"
    t.boolean  "_29d"
    t.text     "_29e",                          :limit => 2147483647
    t.text     "_29f",                          :limit => 2147483647
    t.text     "_30",                           :limit => 2147483647
    t.text     "_31",                           :limit => 2147483647
    t.text     "_32",                           :limit => 2147483647
    t.text     "_33",                           :limit => 2147483647
    t.text     "_34",                           :limit => 2147483647
    t.text     "_35",                           :limit => 2147483647
    t.boolean  "isPaid"
    t.boolean  "isApplyingForStaffInternship"
    t.datetime "createDate"
    t.datetime "lastChangedDate"
    t.integer  "lastChangedBy"
    t.boolean  "isRecruited"
    t.integer  "assignedToProject"
    t.string   "electronicSignature",           :limit => 50
    t.datetime "submittedDate"
    t.datetime "assignedDate"
    t.datetime "acceptedDate"
    t.datetime "notAcceptedDate"
    t.datetime "withdrawnDate"
    t.string   "preferredContactMethod",        :limit => 1
    t.string   "howOftenCheckEmail",            :limit => 30
    t.string   "otherClassDetails",             :limit => 30
    t.boolean  "participateOtherProjects"
    t.boolean  "campusHasStaffTeam"
    t.boolean  "campusHasStaffCoach"
    t.boolean  "campusHasMetroTeam"
    t.boolean  "campusHasOther"
    t.string   "campusHasOtherDetails",         :limit => 30
    t.boolean  "inSchoolNextFall"
    t.boolean  "participateCCC"
    t.boolean  "participateNone"
    t.boolean  "ciPhoneCallRequested"
    t.string   "ciPhoneNumber",                 :limit => 24
    t.string   "ciBestTimeToCall",              :limit => 10
    t.string   "ciTimeZone",                    :limit => 10
    t.string   "_26date",                       :limit => 10
    t.integer  "fk_personID"
  end

  add_index "wsn_sp_wsnapplication_deprecated", ["applAccountNo"], :name => "index10"
  add_index "wsn_sp_wsnapplication_deprecated", ["fk_isMember"], :name => "index1"
  add_index "wsn_sp_wsnapplication_deprecated", ["fk_personID"], :name => "fk_personID"
  add_index "wsn_sp_wsnapplication_deprecated", ["status"], :name => "index8"
  add_index "wsn_sp_wsnapplication_deprecated", ["status"], :name => "status"
  add_index "wsn_sp_wsnapplication_deprecated", ["wsnYear"], :name => "index9"

  create_table "wsn_sp_wsndonations_deprecated", :primary_key => "WsnDonationsID", :force => true do |t|
    t.string "accountno",       :limit => 11
    t.float  "monetary_amount",               :null => false
  end

  add_index "wsn_sp_wsndonations_deprecated", ["accountno"], :name => "accountno"

  create_table "wsn_sp_wsnevaluation_deprecated", :primary_key => "evalID", :force => true do |t|
    t.boolean  "applicantNotified"
    t.integer  "_Qual1"
    t.integer  "_Qual2"
    t.integer  "_Qual3"
    t.integer  "_Qual4"
    t.integer  "_Qual5"
    t.integer  "_Qual6"
    t.integer  "_Qual7"
    t.integer  "_Qual8"
    t.boolean  "_DeQual1"
    t.boolean  "_DeQual2"
    t.boolean  "_DeQual3"
    t.boolean  "_DeQual4"
    t.boolean  "_DeQual5"
    t.boolean  "_DeQual6"
    t.string   "comment",              :limit => 2000
    t.integer  "score"
    t.integer  "fk_WsnApplicationID"
    t.datetime "parent_dateCreated"
    t.boolean  "parent_haveDiscussed"
    t.integer  "parent_advice"
    t.string   "parent_adviceReason",  :limit => 2000
    t.string   "parent_name",          :limit => 100
    t.string   "parent_signature",     :limit => 100
    t.datetime "parent_dateSigned"
  end

  add_index "wsn_sp_wsnevaluation_deprecated", ["fk_WsnApplicationID"], :name => "IX_wsn_sp_WsnEvaluation"

  create_table "wsn_sp_wsnproject_deprecated", :primary_key => "WsnProjectID", :force => true do |t|
    t.string   "name"
    t.string   "partnershipRegion",             :limit => 50
    t.text     "history",                       :limit => 2147483647
    t.string   "startDate"
    t.string   "stopDate"
    t.string   "city"
    t.string   "country"
    t.text     "details",                       :limit => 2147483647
    t.string   "status"
    t.string   "destinationGatewayCity"
    t.string   "departDateFromGateCity"
    t.string   "arrivalDateAtLocation"
    t.string   "locationGatewayCity"
    t.string   "departureDateFromLocation"
    t.string   "arrivalDateAtGatewayCity"
    t.string   "flightBudget"
    t.string   "GatewayCitytoLocationFlightNo"
    t.string   "locationToGatewayCityFlightNo"
    t.string   "inCountryContact"
    t.string   "scholarshipAccountNo"
    t.string   "operatingAccountNo"
    t.string   "AOA"
    t.string   "MPTA"
    t.string   "staffCost"
    t.string   "studentCost"
    t.boolean  "insuranceFormsReceived"
    t.boolean  "CAPSFeePaid"
    t.boolean  "adminFeePaid"
    t.string   "storiesXX"
    t.string   "stats"
    t.boolean  "secure"
    t.string   "dateCreated"
    t.string   "lastUpdate"
    t.integer  "maxNoStaff"
    t.integer  "maxNoStudents"
    t.boolean  "projEvalCompleted"
    t.integer  "evangelisticExposures"
    t.integer  "receivedChrist"
    t.integer  "jesusFilmExposures"
    t.integer  "jesusFilmReveivedChrist"
    t.integer  "coverageActivitiesExposures"
    t.integer  "coverageActivitiesDecisions"
    t.integer  "holySpiritDecisions"
    t.string   "website"
    t.string   "destinationAddress"
    t.string   "destinationPhone"
    t.string   "wsnYear"
    t.integer  "fk_IsCoord"
    t.integer  "fk_IsAPD"
    t.integer  "fk_IsPD"
    t.string   "projectType",                   :limit => 1
    t.datetime "studentStartDate"
    t.datetime "studentEndDate"
    t.datetime "staffStartDate"
    t.datetime "staffEndDate"
    t.datetime "leadershipStartDate"
    t.datetime "leadershipEndDate"
    t.datetime "createDate"
    t.datetime "lastChangedDate"
    t.string   "lastChangedBy",                 :limit => 50
    t.string   "displayLocation",               :limit => 50
    t.boolean  "partnershipRegionOnly"
    t.string   "internCost",                    :limit => 50
    t.boolean  "onHold"
    t.integer  "maxNoStaffMale"
    t.integer  "maxNoStaffFemale"
    t.integer  "maxNoStaffCouples"
    t.integer  "maxNoStaffFamilies"
    t.integer  "maxNoInternAMale"
    t.integer  "maxNoInternAFemale"
    t.integer  "maxNoInternACouples"
    t.integer  "maxNoInternAFamilies"
    t.integer  "maxNoInternA"
    t.integer  "maxNoInternPMale"
    t.integer  "maxNoInternPFemale"
    t.integer  "maxNoInternPCouples"
    t.integer  "maxNoInternPFamilies"
    t.integer  "maxNoInternP"
    t.integer  "maxNoStudentAMale"
    t.integer  "maxNoStudentAFemale"
    t.integer  "maxNoStudentACouples"
    t.integer  "maxNoStudentAFamilies"
    t.integer  "maxNoStudentA"
    t.integer  "maxNoStudentPMale"
    t.integer  "maxNoStudentPFemale"
    t.integer  "maxNoStudentPCouples"
    t.integer  "maxNoStudentPFamilies"
    t.string   "operatingBusinessUnit"
    t.string   "operatingOperatingUnit"
    t.string   "operatingDeptID"
    t.string   "operatingProjectID"
    t.string   "operatingDesignation"
    t.string   "scholarshipBusinessUnit"
    t.string   "scholarshipOperatingUnit"
    t.string   "scholarshipDeptID"
    t.string   "scholarshipProjectID"
    t.string   "scholarshipDesignation"
    t.string   "statesideContactName",          :limit => 45
    t.string   "statesideContactProjectRole",   :limit => 35
    t.string   "statesideContactPhone",         :limit => 20
    t.string   "statesideContactEmail",         :limit => 75
    t.integer  "currentNoStudentAMale"
    t.integer  "currentNoStudentPMale"
    t.integer  "currentNoStudentAFemale"
    t.integer  "currentNoStudentPFemale"
    t.integer  "numApplicants"
  end

  add_index "wsn_sp_wsnproject_deprecated", ["fk_IsAPD"], :name => "index1"
  add_index "wsn_sp_wsnproject_deprecated", ["fk_IsCoord"], :name => "index3"
  add_index "wsn_sp_wsnproject_deprecated", ["fk_IsPD"], :name => "index2"
  add_index "wsn_sp_wsnproject_deprecated", ["name"], :name => "index6"
  add_index "wsn_sp_wsnproject_deprecated", ["partnershipRegion"], :name => "index7"
  add_index "wsn_sp_wsnproject_deprecated", ["status"], :name => "index5"
  add_index "wsn_sp_wsnproject_deprecated", ["wsnYear"], :name => "index4"

  create_table "wsn_sp_wsnusers_deprecated", :primary_key => "wsnUserID", :force => true do |t|
    t.string   "ssmUserName",    :limit => 200
    t.string   "role",           :limit => 50
    t.datetime "expirationDate"
  end

  add_index "wsn_sp_wsnusers_deprecated", ["ssmUserName"], :name => "IX_wsn_sp_WsnUsers_fk_UserName"

  add_foreign_key "crs2_additional_expenses_item", "crs2_expense", :name => "FK385A9FF09F87976B", :column => "expense_id"
  add_foreign_key "crs2_additional_expenses_item", "crs2_expense", :name => "fk_additional_expenses_item_expense_id", :column => "expense_id"
  add_foreign_key "crs2_additional_expenses_item", "crs2_registrant_type", :name => "FK385A9FF0BFB88996", :column => "registrant_type_id"
  add_foreign_key "crs2_additional_expenses_item", "crs2_registrant_type", :name => "fk_additional_expenses_item_registrant_type_id", :column => "registrant_type_id"

  add_foreign_key "crs2_additional_info_item", "crs2_conference", :name => "FKC01086BD863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_additional_info_item", "crs2_conference", :name => "fk_additional_info_item_conference_id", :column => "conference_id"

  add_foreign_key "crs2_answer", "crs2_custom_questions_item", :name => "FK8F185E4F620BBCDE", :column => "question_usage_id"
  add_foreign_key "crs2_answer", "crs2_custom_questions_item", :name => "fk_answer_question_usage_id", :column => "question_usage_id"
  add_foreign_key "crs2_answer", "crs2_registrant", :name => "FK8F185E4FE86BBEBF", :column => "registrant_id"
  add_foreign_key "crs2_answer", "crs2_registrant", :name => "fk_answer_registrant_id", :column => "registrant_id"

  add_foreign_key "crs2_conference", "crs2_url_base", :name => "FK6669B32D7CD5005C", :column => "url_base_id"
  add_foreign_key "crs2_conference", "crs2_url_base", :name => "fk_conference_url_base_id", :column => "url_base_id"
  add_foreign_key "crs2_conference", "crs2_user", :name => "FK6669B32D4EC33E7E", :column => "creator_id"
  add_foreign_key "crs2_conference", "crs2_user", :name => "fk_conference_creator_id", :column => "creator_id"

  add_foreign_key "crs2_configuration", "crs2_url_base", :name => "FK15F201454608DB5E", :column => "default_url_base_id"
  add_foreign_key "crs2_configuration", "crs2_url_base", :name => "fk_configuration_default_url_base_id", :column => "default_url_base_id"

  add_foreign_key "crs2_custom_questions_item", "crs2_question", :name => "FK72AEFAA2FE697289", :column => "question_id"
  add_foreign_key "crs2_custom_questions_item", "crs2_question", :name => "fk_custom_questions_item_question_id", :column => "question_id"
  add_foreign_key "crs2_custom_questions_item", "crs2_registrant_type", :name => "FK72AEFAA2BFB88996", :column => "registrant_type_id"
  add_foreign_key "crs2_custom_questions_item", "crs2_registrant_type", :name => "fk_custom_questions_item_registrant_type_id", :column => "registrant_type_id"

  add_foreign_key "crs2_custom_stylesheet", "crs2_conference", :name => "FKC81CDCAB863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_custom_stylesheet", "crs2_conference", :name => "fk_custom_stylesheet_conference_id", :column => "conference_id"

  add_foreign_key "crs2_expense", "crs2_conference", :name => "FK386A7BE7863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_expense", "crs2_conference", :name => "fk_expense_conference_id", :column => "conference_id"

  add_foreign_key "crs2_expense_selection", "crs2_additional_expenses_item", :name => "FKB9237334168AAE98", :column => "expense_usage_id"
  add_foreign_key "crs2_expense_selection", "crs2_additional_expenses_item", :name => "fk_expense_selection_expense_usage_id", :column => "expense_usage_id"
  add_foreign_key "crs2_expense_selection", "crs2_registrant", :name => "FKB9237334E86BBEBF", :column => "registrant_id"
  add_foreign_key "crs2_expense_selection", "crs2_registrant", :name => "fk_expense_selection_registrant_id", :column => "registrant_id"

  add_foreign_key "crs2_module_usage", "crs2_conference", :name => "FK28233DF863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_module_usage", "crs2_conference", :name => "fk_module_usage_conference_id", :column => "conference_id"

  add_foreign_key "crs2_profile", "crs2_person", :name => "FK74043D38E20F2579", :column => "crs_person_id"
  add_foreign_key "crs2_profile", "crs2_person", :name => "fk_profile_crs_person_id", :column => "crs_person_id"
  add_foreign_key "crs2_profile", "crs2_user", :name => "FK74043D38F3C73A7F", :column => "user_id"
  add_foreign_key "crs2_profile", "crs2_user", :name => "fk_profile_user_id", :column => "user_id"
  add_foreign_key "crs2_profile", "people", :name => "FK74043D38E8E728C3", :column => "ministry_person_id", :primary_key => "personID"
  add_foreign_key "crs2_profile", "people", :name => "fk_profile_ministry_person_id", :column => "ministry_person_id", :primary_key => "personID"

  add_foreign_key "crs2_profile_question", "crs2_registrant_type", :name => "FK80688F0DBFB88996", :column => "registrant_type_id"
  add_foreign_key "crs2_profile_question", "crs2_registrant_type", :name => "fk_profile_question_registrant_type_id", :column => "registrant_type_id"

  add_foreign_key "crs2_question", "crs2_conference", :name => "FK2C2FA37863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_question", "crs2_conference", :name => "fk_question_conference_id", :column => "conference_id"

  add_foreign_key "crs2_question_option", "crs2_question", :name => "FK5B6AEF7D5D2F9214", :column => "option_question_id"
  add_foreign_key "crs2_question_option", "crs2_question", :name => "fk_question_option_option_question_id", :column => "option_question_id"

  add_foreign_key "crs2_registrant", "crs2_profile", :name => "FKCB9B36BC2442AF81", :column => "profile_id"
  add_foreign_key "crs2_registrant", "crs2_profile", :name => "fk_registrant_profile_id", :column => "profile_id"
  add_foreign_key "crs2_registrant", "crs2_registrant_type", :name => "FKCB9B36BC33BE6712", :column => "registrant_type_before_cancellation_id"
  add_foreign_key "crs2_registrant", "crs2_registrant_type", :name => "FKCB9B36BCBFB88996", :column => "registrant_type_id"
  add_foreign_key "crs2_registrant", "crs2_registrant_type", :name => "fk_registrant_registrant_type_before_cancellation_id", :column => "registrant_type_before_cancellation_id"
  add_foreign_key "crs2_registrant", "crs2_registrant_type", :name => "fk_registrant_registrant_type_id", :column => "registrant_type_id"
  add_foreign_key "crs2_registrant", "crs2_registration", :name => "FKCB9B36BC8FD067BB", :column => "registration_before_cancellation_id"
  add_foreign_key "crs2_registrant", "crs2_registration", :name => "FKCB9B36BCA7FD76BF", :column => "registration_id"
  add_foreign_key "crs2_registrant", "crs2_registration", :name => "fk_registrant_registration_before_cancellation_id", :column => "registration_before_cancellation_id"
  add_foreign_key "crs2_registrant", "crs2_registration", :name => "fk_registrant_registration_id", :column => "registration_id"
  add_foreign_key "crs2_registrant", "crs2_user", :name => "FKCB9B36BC6F044A05", :column => "cancelled_by_id"
  add_foreign_key "crs2_registrant", "crs2_user", :name => "fk_registrant_cancelled_by_id", :column => "cancelled_by_id"

  add_foreign_key "crs2_registrant_type", "crs2_conference", :name => "FKA936E6DD863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_registrant_type", "crs2_conference", :name => "fk_registrant_type_conference_id", :column => "conference_id"

  add_foreign_key "crs2_registration", "crs2_user", :name => "FK51AB168A4EC33E7E", :column => "creator_id"
  add_foreign_key "crs2_registration", "crs2_user", :name => "FK51AB168A6F044A05", :column => "cancelled_by_id"
  add_foreign_key "crs2_registration", "crs2_user", :name => "fk_registration_creator_id", :column => "creator_id"

  add_foreign_key "crs2_transaction", "crs2_conference", :name => "FKA5E426ED863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_transaction", "crs2_conference", :name => "fk_transaction_conference_id", :column => "conference_id"
  add_foreign_key "crs2_transaction", "crs2_expense_selection", :name => "FKA5E426ED744633B8", :column => "expense_selection_id"
  add_foreign_key "crs2_transaction", "crs2_expense_selection", :name => "fk_transaction_expense_selection_id", :column => "expense_selection_id"
  add_foreign_key "crs2_transaction", "crs2_registrant", :name => "FKA5E426EDE86BBEBF", :column => "registrant_id"
  add_foreign_key "crs2_transaction", "crs2_registrant", :name => "fk_transaction_registrant_id", :column => "registrant_id"
  add_foreign_key "crs2_transaction", "crs2_registration", :name => "FKA5E426EDA7FD76BF", :column => "registration_id"
  add_foreign_key "crs2_transaction", "crs2_registration", :name => "fk_transaction_registration_id", :column => "registration_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "FKA5E426ED4FA3400A", :column => "scholarship_charge_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "FKA5E426ED6A74B681", :column => "paid_by_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "FKA5E426ED6E748998", :column => "charge_cancellation_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "FKA5E426EDFBB004F2", :column => "payment_cancellation_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "fk_transaction_charge_cancellation_id", :column => "charge_cancellation_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "fk_transaction_paid_by_id", :column => "paid_by_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "fk_transaction_payment_cancellation_id", :column => "payment_cancellation_id"
  add_foreign_key "crs2_transaction", "crs2_transaction", :name => "fk_transaction_scholarship_charge_id", :column => "scholarship_charge_id"
  add_foreign_key "crs2_transaction", "crs2_user", :name => "FKA5E426ED24360A3C", :column => "verified_by_id"
  add_foreign_key "crs2_transaction", "crs2_user", :name => "FKA5E426EDF3C73A7F", :column => "user_id"
  add_foreign_key "crs2_transaction", "crs2_user", :name => "fk_transaction_user_id", :column => "user_id"
  add_foreign_key "crs2_transaction", "crs2_user", :name => "fk_transaction_verified_by_id", :column => "verified_by_id"

  add_foreign_key "crs2_user_role", "crs2_conference", :name => "FKD4130039863D9D1F", :column => "conference_id"
  add_foreign_key "crs2_user_role", "crs2_conference", :name => "fk_user_rule_conference_id", :column => "conference_id"
  add_foreign_key "crs2_user_role", "crs2_user", :name => "FKD4130039F3C73A7F", :column => "user_id"
  add_foreign_key "crs2_user_role", "crs2_user", :name => "fk_user_rule_user_id", :column => "user_id"

  add_foreign_key "sp_page_elements", "sp_elements", :name => "sp_page_elements_ibfk_2", :column => "element_id", :dependent => :delete
  add_foreign_key "sp_page_elements", "sp_pages", :name => "sp_page_elements_ibfk_1", :column => "page_id", :dependent => :delete

>>>>>>> Stashed changes
end
