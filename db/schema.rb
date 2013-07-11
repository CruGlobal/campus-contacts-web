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

ActiveRecord::Schema.define(:version => 20130711183515) do

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
    t.string   "address1"
    t.string   "address2"
    t.string   "address3",     :limit => 55
    t.string   "address4",     :limit => 55
    t.string   "city",         :limit => 50
    t.string   "state",        :limit => 50
    t.string   "zip",          :limit => 15
    t.string   "country",      :limit => 64
    t.string   "address_type", :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "dorm"
    t.string   "room"
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
    t.string   "mobile_token"
  end

  add_index "authentications", ["provider", "mobile_token"], :name => "provider_token"
  add_index "authentications", ["uid", "provider"], :name => "uid_provider", :unique => true

  create_table "chart_organizations", :force => true do |t|
    t.integer  "chart_id"
    t.integer  "organization_id"
    t.boolean  "snapshot_display", :default => true
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "chart_organizations", ["chart_id", "organization_id"], :name => "index_chart_organizations_on_chart_id_and_organization_id", :unique => true
  add_index "chart_organizations", ["chart_id"], :name => "index_chart_organizations_on_chart_id"
  add_index "chart_organizations", ["organization_id"], :name => "index_chart_organizations_on_organization_id"

  create_table "charts", :force => true do |t|
    t.integer  "person_id"
    t.string   "chart_type"
    t.boolean  "snapshot_all_movements",  :default => true
    t.integer  "snapshot_evang_range",    :default => 6
    t.integer  "snapsnot_laborers_range", :default => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "charts", ["chart_type"], :name => "index_charts_on_chart_type"
  add_index "charts", ["person_id", "chart_type"], :name => "index_charts_on_person_id_and_chart_type", :unique => true
  add_index "charts", ["person_id"], :name => "index_charts_on_person_id"

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
  add_index "elements", ["kind"], :name => "index_elements_on_kind"
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
    t.text     "preview"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "imports", ["organization_id"], :name => "index_mh_imports_on_organization_id"
  add_index "imports", ["user_id", "organization_id"], :name => "user_org"

  create_table "interaction_initiators", :force => true do |t|
    t.integer  "person_id"
    t.integer  "interaction_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "interaction_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "i18n"
    t.string   "icon"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "interactions", :force => true do |t|
    t.integer  "interaction_type_id"
    t.integer  "receiver_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "organization_id"
    t.string   "comment"
    t.string   "privacy_setting"
    t.datetime "timestamp"
    t.datetime "deleted_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "interactions", ["created_at"], :name => "index_interactions_on_created_at"

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

  create_table "labels", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "i18n"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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

  create_table "messages", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "person_id"
    t.integer  "receiver_id"
    t.string   "from"
    t.string   "to"
    t.string   "reply_to"
    t.string   "subject"
    t.text     "message"
    t.string   "status"
    t.string   "sent_via"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "movement_indicator_suggestions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "organization_id"
    t.integer  "label_id"
    t.boolean  "accepted"
    t.string   "reason",          :limit => 1000
    t.string   "action",                          :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "movement_indicator_suggestions", ["organization_id", "person_id", "label_id", "action"], :name => "person_organization_label"
  add_index "movement_indicator_suggestions", ["organization_id", "person_id"], :name => "person_organization"

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

  create_table "organizational_labels", :force => true do |t|
    t.integer  "person_id"
    t.integer  "label_id"
    t.integer  "organization_id"
    t.date     "start_date"
    t.integer  "added_by_id"
    t.date     "removed_date"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "organizational_permissions", :force => true do |t|
    t.integer  "person_id"
    t.integer  "permission_id"
    t.date     "start_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.string   "followup_status"
    t.integer  "added_by_id"
    t.datetime "archive_date"
  end

  add_index "organizational_permissions", ["organization_id", "permission_id", "followup_status"], :name => "role_org_status"
  add_index "organizational_permissions", ["person_id", "organization_id", "permission_id"], :name => "person_role_org", :unique => true

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.boolean  "requires_validation",          :default => false
    t.string   "validation_method"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.string   "terminology"
    t.integer  "importable_id"
    t.string   "importable_type"
    t.boolean  "show_sub_orgs",                :default => false,    :null => false
    t.string   "status",                       :default => "active", :null => false
    t.text     "settings"
    t.integer  "conference_id"
    t.datetime "last_indicator_suggestion_at"
    t.date     "last_push_to_infobase"
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
    t.string   "campus",                        :limit => 128
    t.string   "year_in_school",                :limit => 20
    t.string   "major",                         :limit => 70
    t.string   "minor",                         :limit => 70
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
    t.integer  "crs_profile_id"
    t.integer  "sp_person_id"
    t.integer  "si_person_id"
    t.integer  "pr_person_id"
    t.boolean  "faculty",                                      :default => false, :null => false
    t.boolean  "is_staff",                                     :default => false, :null => false
    t.integer  "infobase_person_id"
    t.string   "nationality"
  end

  add_index "people", ["accountNo"], :name => "accountNo_ministry_Person"
  add_index "people", ["campus"], :name => "campus"
  add_index "people", ["crs_profile_id"], :name => "index_people_on_crs_profile_id"
  add_index "people", ["fb_uid"], :name => "index_ministry_person_on_fb_uid"
  add_index "people", ["first_name", "last_name"], :name => "firstName_lastName"
  add_index "people", ["infobase_person_id"], :name => "index_people_on_infobase_person_id"
  add_index "people", ["last_name"], :name => "lastname_ministry_Person"
  add_index "people", ["pr_person_id"], :name => "index_people_on_pr_person_id"
  add_index "people", ["si_person_id"], :name => "index_people_on_si_person_id"
  add_index "people", ["sp_person_id"], :name => "index_people_on_sp_person_id"
  add_index "people", ["user_id"], :name => "fk_ssmUserId"

  create_table "permissions", :force => true do |t|
    t.string   "name"
    t.string   "i18n"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "full_path",       :limit => 4000
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
  end

  add_index "saved_contact_searches", ["user_id"], :name => "index_saved_contact_searches_on_user_id"

  create_table "school_years", :force => true do |t|
    t.string   "name"
    t.string   "level"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sent_people", :force => true do |t|
    t.integer  "person_id"
    t.integer  "transferred_by_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
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
    t.string   "title",                  :limit => 100,  :default => "",       :null => false
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "post_survey_message"
    t.string   "terminology",                            :default => "Survey"
    t.integer  "login_option",                           :default => 0
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
    t.string   "redirect_url",           :limit => 2000
  end

  add_index "surveys", ["crs_registrant_type_id"], :name => "index_surveys_on_crs_registrant_type_id"
  add_index "surveys", ["organization_id"], :name => "index_mh_surveys_on_organization_id"

  create_table "users", :force => true do |t|
    t.string   "username",                  :limit => 200,                :null => false
    t.string   "password",                  :limit => 80
    t.datetime "lastLogin"
    t.datetime "createdOn"
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

  create_table "versions", :force => true do |t|
    t.string   "item_type",       :null => false
    t.integer  "item_id",         :null => false
    t.string   "event",           :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.integer  "organization_id"
    t.integer  "person_id"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"
  add_index "versions", ["organization_id", "created_at"], :name => "index_versions_on_organization_id_and_created_at"
  add_index "versions", ["person_id", "created_at"], :name => "index_versions_on_person_id_and_created_at"

  add_foreign_key "answers", "elements", :name => "answers_ibfk_1", :column => "question_id"

  add_foreign_key "organization_memberships", "organizations", :name => "organization_memberships_ibfk_2", :dependent => :delete

  add_foreign_key "organizational_permissions", "organizations", :name => "organizational_permissions_ibfk_1", :dependent => :delete

  add_foreign_key "sms_keywords", "organizations", :name => "sms_keywords_ibfk_4", :dependent => :delete
  add_foreign_key "sms_keywords", "surveys", :name => "sms_keywords_ibfk_3", :dependent => :nullify

  add_foreign_key "surveys", "organizations", :name => "surveys_ibfk_1", :dependent => :delete

end
