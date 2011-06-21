CREATE TABLE `academic_departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `access_grants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `identity` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `granted_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `revoked` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_access_grants_on_code` (`code`),
  KEY `index_access_grants_on_client_id` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8;

CREATE TABLE `access_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `identity` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `revoked` datetime DEFAULT NULL,
  `last_access` datetime DEFAULT NULL,
  `prev_access` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_access_tokens_on_code` (`code`),
  KEY `index_access_tokens_on_client_id` (`client_id`),
  KEY `index_access_tokens_on_identity` (`identity`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_area_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` varchar(255) DEFAULT 'active',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_activities_on_target_area_id_and_organization_id` (`target_area_id`,`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `aoas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

CREATE TABLE `auth_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `response_type` varchar(255) DEFAULT NULL,
  `grant_code` varchar(255) DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `authorized_at` datetime DEFAULT NULL,
  `revoked` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_auth_requests_on_code` (`code`),
  KEY `index_auth_requests_on_client_id` (`client_id`)
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8;

CREATE TABLE `authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_authentications_on_provider_and_uid` (`provider`,`uid`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;

CREATE TABLE `client_applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `app_id` varchar(255) DEFAULT NULL,
  `app_secret` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(20) DEFAULT NULL,
  `url` varchar(60) DEFAULT NULL,
  `callback_url` varchar(60) DEFAULT NULL,
  `support_url` varchar(60) DEFAULT NULL,
  `key` varchar(60) DEFAULT NULL,
  `secret` varchar(60) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `revoked` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_clients_on_code` (`code`),
  UNIQUE KEY `index_clients_on_display_name` (`display_name`),
  UNIQUE KEY `index_clients_on_link` (`link`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

CREATE TABLE `cms_assoc_filecategory` (
  `CmsFileID` varchar(64) NOT NULL,
  `CmsCategoryID` varchar(64) NOT NULL,
  `dbioDummy` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`CmsFileID`,`CmsCategoryID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cms_cmscategory` (
  `CmsCategoryID` int(10) NOT NULL AUTO_INCREMENT,
  `parentCategory` int(10) DEFAULT NULL,
  `catName` varchar(256) DEFAULT NULL,
  `catDesc` varchar(2000) DEFAULT NULL,
  `path` varchar(2000) DEFAULT NULL,
  `pathid` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`CmsCategoryID`),
  KEY `index1` (`parentCategory`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cms_cmsfile` (
  `CmsFileID` int(10) NOT NULL AUTO_INCREMENT,
  `mime` varchar(128) DEFAULT NULL,
  `title` varchar(256) DEFAULT NULL,
  `accessCount` int(10) DEFAULT NULL,
  `dateAdded` datetime DEFAULT NULL,
  `dateModified` datetime DEFAULT NULL,
  `moderatedYet` char(1) DEFAULT NULL,
  `summary` varchar(5000) DEFAULT NULL,
  `quality` varchar(256) DEFAULT NULL,
  `expDate` datetime DEFAULT NULL,
  `lastAccessed` datetime DEFAULT NULL,
  `modMsg` varchar(4000) DEFAULT NULL,
  `keywords` varchar(4000) DEFAULT NULL,
  `url` varchar(128) DEFAULT NULL,
  `detail` varchar(4000) DEFAULT NULL,
  `language` varchar(128) DEFAULT NULL,
  `version` varchar(128) DEFAULT NULL,
  `author` varchar(256) DEFAULT NULL,
  `submitter` varchar(256) DEFAULT NULL,
  `contact` varchar(256) DEFAULT NULL,
  `rating` int(10) DEFAULT NULL,
  PRIMARY KEY (`CmsFileID`),
  KEY `index1` (`accessCount`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `communities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `fbpage` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `school_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `community_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `contact_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assigned_to_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `counties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `state` (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `country` varchar(100) DEFAULT NULL,
  `code` varchar(10) DEFAULT NULL,
  `closed` tinyint(1) DEFAULT '0',
  `iso_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=248 DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_additional_expenses_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `location` int(11) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  `header` varchar(255) DEFAULT NULL,
  `text` text,
  `expense_id` int(20) DEFAULT NULL,
  `registrant_type_id` int(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_registrant_type_expense` (`registrant_type_id`,`expense_id`),
  KEY `fk_additional_expenses_item_registrant_type_id` (`registrant_type_id`),
  KEY `fk_additional_expenses_item_expense_id` (`expense_id`),
  CONSTRAINT `fk_additional_expenses_item_expense_id` FOREIGN KEY (`expense_id`) REFERENCES `crs2_expense` (`id`),
  CONSTRAINT `fk_additional_expenses_item_registrant_type_id` FOREIGN KEY (`registrant_type_id`) REFERENCES `crs2_registrant_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_additional_info_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `location` int(11) NOT NULL,
  `text` text,
  `title` varchar(60) DEFAULT NULL,
  `conference_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_additional_info_item_conference_id` (`conference_id`),
  CONSTRAINT `fk_additional_info_item_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_answer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `value_boolean` tinyint(1) DEFAULT NULL,
  `value_date` date DEFAULT NULL,
  `value_double` float DEFAULT NULL,
  `value_int` int(11) DEFAULT NULL,
  `value_string` varchar(255) DEFAULT NULL,
  `value_text` text,
  `question_usage_id` int(20) NOT NULL,
  `registrant_id` int(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_registrant_question_usage` (`registrant_id`,`question_usage_id`),
  KEY `fk_answer_registrant_id` (`registrant_id`),
  KEY `fk_answer_question_usage_id` (`question_usage_id`),
  CONSTRAINT `fk_answer_question_usage_id` FOREIGN KEY (`question_usage_id`) REFERENCES `crs2_custom_questions_item` (`id`),
  CONSTRAINT `fk_answer_registrant_id` FOREIGN KEY (`registrant_id`) REFERENCES `crs2_registrant` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_conference` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `accept_american_express` tinyint(1) DEFAULT NULL,
  `accept_discover` tinyint(1) DEFAULT NULL,
  `accept_master_card` tinyint(1) DEFAULT NULL,
  `accept_scholarships` tinyint(1) DEFAULT NULL,
  `accept_visa` tinyint(1) DEFAULT NULL,
  `admin_password` varchar(255) NOT NULL DEFAULT '',
  `authnet_api_login_id` varchar(255) DEFAULT NULL,
  `authnet_transaction_key` varchar(255) DEFAULT NULL,
  `begin_date` date NOT NULL,
  `check_payable_to` varchar(255) DEFAULT NULL,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `description` text,
  `end_date` date NOT NULL,
  `ministry_type` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `offer_families_extra_rooms` tinyint(1) DEFAULT NULL,
  `power_user_password` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `registration_ends_at` datetime NOT NULL,
  `registration_starts_at` datetime NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT '',
  `theme` varchar(255) DEFAULT NULL,
  `url_base_id` int(20) DEFAULT NULL,
  `creator_id` int(20) NOT NULL,
  `home_page_address` varchar(255) DEFAULT NULL,
  `ride_share` tinyint(1) DEFAULT NULL,
  `event_address1` varchar(255) DEFAULT NULL,
  `event_address2` varchar(255) DEFAULT NULL,
  `event_city` varchar(255) DEFAULT NULL,
  `event_state` varchar(255) DEFAULT NULL,
  `event_zip` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_name` (`name`),
  KEY `fk_conference_url_base_id` (`url_base_id`),
  KEY `fk_conference_creator_id` (`creator_id`),
  CONSTRAINT `fk_conference_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `crs2_user` (`id`),
  CONSTRAINT `fk_conference_url_base_id` FOREIGN KEY (`url_base_id`) REFERENCES `crs2_url_base` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_configuration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `added_builtin_common_questions` tinyint(1) DEFAULT NULL,
  `default_url_base_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_configuration_default_url_base_id` (`default_url_base_id`),
  CONSTRAINT `fk_configuration_default_url_base_id` FOREIGN KEY (`default_url_base_id`) REFERENCES `crs2_url_base` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_custom_questions_item` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `location` int(11) NOT NULL,
  `text` text,
  `required` tinyint(1) DEFAULT NULL,
  `registrant_type_id` int(20) NOT NULL,
  `question_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_registrant_type_question` (`registrant_type_id`,`question_id`),
  KEY `fk_custom_questions_item_registrant_type_id` (`registrant_type_id`),
  KEY `fk_custom_questions_item_question_id` (`question_id`),
  CONSTRAINT `fk_custom_questions_item_question_id` FOREIGN KEY (`question_id`) REFERENCES `crs2_question` (`id`),
  CONSTRAINT `fk_custom_questions_item_registrant_type_id` FOREIGN KEY (`registrant_type_id`) REFERENCES `crs2_registrant_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_custom_stylesheet` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `customcss` text,
  `conference_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_custom_stylesheet_conference_id` (`conference_id`),
  CONSTRAINT `fk_custom_stylesheet_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_expense` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `cost` decimal(12,2) DEFAULT NULL,
  `description` text,
  `name` varchar(60) DEFAULT NULL,
  `conference_id` int(20) NOT NULL,
  `disabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_expense_conference_id` (`conference_id`),
  CONSTRAINT `fk_expense_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_expense_selection` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `selected` tinyint(1) DEFAULT NULL,
  `registrant_id` int(20) NOT NULL,
  `expense_usage_id` int(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_registrant_expense_usage` (`registrant_id`,`expense_usage_id`),
  KEY `fk_expense_selection_registrant_id` (`registrant_id`),
  KEY `fk_expense_selection_expense_usage_id` (`expense_usage_id`),
  CONSTRAINT `fk_expense_selection_expense_usage_id` FOREIGN KEY (`expense_usage_id`) REFERENCES `crs2_additional_expenses_item` (`id`),
  CONSTRAINT `fk_expense_selection_registrant_id` FOREIGN KEY (`registrant_id`) REFERENCES `crs2_registrant` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_module_usage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `conference_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_module_usage_conference_id` (`conference_id`),
  CONSTRAINT `fk_module_usage_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_person` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `birth_date` datetime DEFAULT NULL,
  `campus` varchar(255) DEFAULT NULL,
  `current_address1` varchar(255) DEFAULT NULL,
  `current_address2` varchar(255) DEFAULT NULL,
  `current_city` varchar(255) DEFAULT NULL,
  `current_country` varchar(255) DEFAULT NULL,
  `current_phone` varchar(255) DEFAULT NULL,
  `current_state` varchar(255) DEFAULT NULL,
  `current_zip` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `graduation_date` datetime DEFAULT NULL,
  `greek_affiliation` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `major` varchar(255) DEFAULT NULL,
  `marital_status` varchar(255) DEFAULT NULL,
  `middle_name` varchar(255) DEFAULT NULL,
  `permanent_address1` varchar(255) DEFAULT NULL,
  `permanent_address2` varchar(255) DEFAULT NULL,
  `permanent_city` varchar(255) DEFAULT NULL,
  `permanent_country` varchar(255) DEFAULT NULL,
  `permanent_phone` varchar(255) DEFAULT NULL,
  `permanent_state` varchar(255) DEFAULT NULL,
  `permanent_zip` varchar(255) DEFAULT NULL,
  `university_state` varchar(255) DEFAULT NULL,
  `year_in_school` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_profile` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `crs_person_id` int(20) DEFAULT NULL,
  `user_id` int(20) DEFAULT NULL,
  `ministry_person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_crs_person` (`crs_person_id`),
  UNIQUE KEY `unique_user` (`user_id`),
  UNIQUE KEY `unique_ministry_person` (`ministry_person_id`),
  KEY `fk_profile_user_id` (`user_id`),
  KEY `fk_profile_ministry_person_id` (`ministry_person_id`),
  KEY `fk_profile_crs_person_id` (`crs_person_id`),
  CONSTRAINT `fk_profile_crs_person_id` FOREIGN KEY (`crs_person_id`) REFERENCES `crs2_person` (`id`),
  CONSTRAINT `fk_profile_ministry_person_id` FOREIGN KEY (`ministry_person_id`) REFERENCES `ministry_person` (`personID`),
  CONSTRAINT `fk_profile_user_id` FOREIGN KEY (`user_id`) REFERENCES `crs2_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_profile_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `property_name` varchar(255) NOT NULL DEFAULT '',
  `requirement` int(11) NOT NULL,
  `registrant_type_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_profile_question_registrant_type_id` (`registrant_type_id`),
  CONSTRAINT `fk_profile_question_registrant_type_id` FOREIGN KEY (`registrant_type_id`) REFERENCES `crs2_registrant_type` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `common` tinyint(1) DEFAULT NULL,
  `name` varchar(60) NOT NULL DEFAULT '',
  `text` text NOT NULL,
  `conference_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_name_conference` (`name`,`conference_id`),
  KEY `fk_question_conference_id` (`conference_id`),
  CONSTRAINT `fk_question_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_question_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `location` int(11) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  `option_question_id` int(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_option_question_value` (`option_question_id`,`value`),
  UNIQUE KEY `unique_option_question_name` (`option_question_id`,`name`),
  KEY `fk_question_option_option_question_id` (`option_question_id`),
  CONSTRAINT `fk_question_option_option_question_id` FOREIGN KEY (`option_question_id`) REFERENCES `crs2_question` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_registrant` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `arrival_date` date DEFAULT NULL,
  `began_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `commuting` tinyint(1) DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `departure_date` date DEFAULT NULL,
  `registrant_role` varchar(255) DEFAULT NULL,
  `requires_childcare` tinyint(1) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT '',
  `registration_before_cancellation_id` int(20) DEFAULT NULL,
  `cancelled_by_id` int(20) DEFAULT NULL,
  `profile_id` int(20) NOT NULL,
  `registrant_type_id` int(20) DEFAULT NULL,
  `registrant_type_before_cancellation_id` int(20) DEFAULT NULL,
  `registration_id` int(20) DEFAULT NULL,
  `early_registration_override` varchar(255) DEFAULT NULL,
  `name_disabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_profile_registrant_type` (`profile_id`,`registrant_type_id`),
  KEY `fk_registrant_registration_before_cancellation_id` (`registration_before_cancellation_id`),
  KEY `fk_registrant_registrant_type_before_cancellation_id` (`registrant_type_before_cancellation_id`),
  KEY `fk_registrant_registrant_type_id` (`registrant_type_id`),
  KEY `fk_registrant_profile_id` (`profile_id`),
  KEY `fk_registrant_cancelled_by_id` (`cancelled_by_id`),
  KEY `fk_registrant_registration_id` (`registration_id`),
  CONSTRAINT `fk_registrant_cancelled_by_id` FOREIGN KEY (`cancelled_by_id`) REFERENCES `crs2_user` (`id`),
  CONSTRAINT `fk_registrant_profile_id` FOREIGN KEY (`profile_id`) REFERENCES `crs2_profile` (`id`),
  CONSTRAINT `fk_registrant_registrant_type_before_cancellation_id` FOREIGN KEY (`registrant_type_before_cancellation_id`) REFERENCES `crs2_registrant_type` (`id`),
  CONSTRAINT `fk_registrant_registrant_type_id` FOREIGN KEY (`registrant_type_id`) REFERENCES `crs2_registrant_type` (`id`),
  CONSTRAINT `fk_registrant_registration_before_cancellation_id` FOREIGN KEY (`registration_before_cancellation_id`) REFERENCES `crs2_registration` (`id`),
  CONSTRAINT `fk_registrant_registration_id` FOREIGN KEY (`registration_id`) REFERENCES `crs2_registration` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_registrant_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `accept_checks` tinyint(1) DEFAULT NULL,
  `accept_credit_cards` tinyint(1) DEFAULT NULL,
  `accept_ministry_account_transfers` tinyint(1) DEFAULT NULL,
  `accept_scholarships` tinyint(1) DEFAULT NULL,
  `accept_staff_account_transfers` tinyint(1) DEFAULT NULL,
  `additional_confirmation_email_text` text,
  `allow_children` tinyint(1) DEFAULT NULL,
  `allow_commute` tinyint(1) DEFAULT NULL,
  `allow_spouse` tinyint(1) DEFAULT NULL,
  `ask_arrival_date` tinyint(1) DEFAULT NULL,
  `ask_departure_date` tinyint(1) DEFAULT NULL,
  `childcare_available` tinyint(1) DEFAULT NULL,
  `default_arrival_date` date DEFAULT NULL,
  `default_departure_date` date DEFAULT NULL,
  `description` text NOT NULL,
  `is_child_type` tinyint(1) DEFAULT NULL,
  `married_commuter_cost` decimal(12,2) DEFAULT NULL,
  `married_commuter_early_reg_discount` decimal(12,2) DEFAULT NULL,
  `married_commuter_full_payment_discount` decimal(12,2) DEFAULT NULL,
  `married_discount_early_registration_deadline` datetime DEFAULT NULL,
  `married_onsite_cost` decimal(12,2) DEFAULT NULL,
  `married_onsite_early_reg_discount` decimal(12,2) DEFAULT NULL,
  `married_onsite_full_payment_discount` decimal(12,2) DEFAULT NULL,
  `married_required_deposit` decimal(12,2) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `offer_childcare` tinyint(1) DEFAULT NULL,
  `registration_complete_email` text,
  `single_commuter_cost` decimal(12,2) DEFAULT NULL,
  `single_commuter_early_reg_discount` decimal(12,2) DEFAULT NULL,
  `single_commuter_full_payment_discount` decimal(12,2) DEFAULT NULL,
  `single_discount_early_registration_deadline` datetime DEFAULT NULL,
  `single_onsite_cost` decimal(12,2) DEFAULT NULL,
  `single_onsite_early_reg_discount` decimal(12,2) DEFAULT NULL,
  `single_onsite_full_payment_discount` decimal(12,2) DEFAULT NULL,
  `single_required_deposit` decimal(12,2) DEFAULT NULL,
  `conference_id` int(20) NOT NULL,
  `defer_online_payment` tinyint(1) DEFAULT NULL,
  `require_full_payment` tinyint(1) DEFAULT NULL,
  `shut_off` tinyint(1) DEFAULT NULL,
  `shut_off_message` text,
  PRIMARY KEY (`id`),
  KEY `fk_registrant_type_conference_id` (`conference_id`),
  CONSTRAINT `fk_registrant_type_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_registration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `began_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` blob,
  `completed_at` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT '',
  `extra_rooms` int(11) DEFAULT NULL,
  `creator_id` int(20) DEFAULT NULL,
  `cancelled_by_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_registration_creator_id` (`creator_id`),
  CONSTRAINT `fk_registration_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `crs2_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_transaction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `comment` text,
  `effective_date` datetime DEFAULT NULL,
  `debit` decimal(12,2) DEFAULT NULL,
  `married` tinyint(1) DEFAULT NULL,
  `transaction_cancellation` blob,
  `commuter` tinyint(1) DEFAULT NULL,
  `credit` decimal(12,2) DEFAULT NULL,
  `abbreviated_card_number` varchar(255) DEFAULT NULL,
  `authorization_code` varchar(255) DEFAULT NULL,
  `business_unit` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `ministry` varchar(255) DEFAULT NULL,
  `operating_unit` varchar(255) DEFAULT NULL,
  `project` varchar(255) DEFAULT NULL,
  `override` tinyint(1) DEFAULT NULL,
  `designation_no` varchar(7) DEFAULT NULL,
  `authorizer_id` int(11) DEFAULT NULL,
  `verified_by_id` int(20) DEFAULT NULL,
  `expense_selection_id` int(20) DEFAULT NULL,
  `charge_cancellation_id` int(20) DEFAULT NULL,
  `paid_by_id` int(20) DEFAULT NULL,
  `indicated_verifier_id` int(11) DEFAULT NULL,
  `payment_cancellation_id` int(20) DEFAULT NULL,
  `registration_id` int(20) DEFAULT NULL,
  `scholarship_charge_id` int(20) DEFAULT NULL,
  `conference_id` int(20) DEFAULT NULL,
  `registrant_id` int(20) DEFAULT NULL,
  `user_id` int(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_transaction_user_id` (`user_id`),
  KEY `fk_transaction_paid_by_id` (`paid_by_id`),
  KEY `fk_transaction_verified_by_id` (`verified_by_id`),
  KEY `fk_transaction_scholarship_charge_id` (`scholarship_charge_id`),
  KEY `fk_transaction_charge_cancellation_id` (`charge_cancellation_id`),
  KEY `fk_transaction_registrant_id` (`registrant_id`),
  KEY `fk_transaction_indicated_verifier_id` (`indicated_verifier_id`),
  KEY `fk_transaction_payment_cancellation_id` (`payment_cancellation_id`),
  KEY `fk_transaction_expense_selection_id` (`expense_selection_id`),
  KEY `fk_transaction_authorizer_id` (`authorizer_id`),
  KEY `fk_transaction_conference_id` (`conference_id`),
  KEY `fk_transaction_registration_id` (`registration_id`),
  CONSTRAINT `fk_transaction_charge_cancellation_id` FOREIGN KEY (`charge_cancellation_id`) REFERENCES `crs2_transaction` (`id`),
  CONSTRAINT `fk_transaction_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`),
  CONSTRAINT `fk_transaction_expense_selection_id` FOREIGN KEY (`expense_selection_id`) REFERENCES `crs2_expense_selection` (`id`),
  CONSTRAINT `fk_transaction_paid_by_id` FOREIGN KEY (`paid_by_id`) REFERENCES `crs2_transaction` (`id`),
  CONSTRAINT `fk_transaction_payment_cancellation_id` FOREIGN KEY (`payment_cancellation_id`) REFERENCES `crs2_transaction` (`id`),
  CONSTRAINT `fk_transaction_registrant_id` FOREIGN KEY (`registrant_id`) REFERENCES `crs2_registrant` (`id`),
  CONSTRAINT `fk_transaction_registration_id` FOREIGN KEY (`registration_id`) REFERENCES `crs2_registration` (`id`),
  CONSTRAINT `fk_transaction_scholarship_charge_id` FOREIGN KEY (`scholarship_charge_id`) REFERENCES `crs2_transaction` (`id`),
  CONSTRAINT `fk_transaction_user_id` FOREIGN KEY (`user_id`) REFERENCES `crs2_user` (`id`),
  CONSTRAINT `fk_transaction_verified_by_id` FOREIGN KEY (`verified_by_id`) REFERENCES `crs2_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_url_base` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `authority` varchar(255) NOT NULL DEFAULT '',
  `scheme` varchar(5) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs2_user_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(31) NOT NULL DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `version` int(11) NOT NULL,
  `conference_id` int(20) DEFAULT NULL,
  `user_id` int(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_rule_user_id` (`user_id`),
  KEY `fk_user_rule_conference_id` (`conference_id`),
  CONSTRAINT `fk_user_rule_conference_id` FOREIGN KEY (`conference_id`) REFERENCES `crs2_conference` (`id`),
  CONSTRAINT `fk_user_rule_user_id` FOREIGN KEY (`user_id`) REFERENCES `crs2_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_answer` (
  `answerID` int(10) NOT NULL AUTO_INCREMENT,
  `body` varchar(7000) DEFAULT NULL,
  `fk_QuestionID` int(10) DEFAULT NULL,
  `fk_RegistrationID` int(10) DEFAULT NULL,
  PRIMARY KEY (`answerID`),
  KEY `fk_QuestionID` (`fk_QuestionID`,`fk_RegistrationID`),
  KEY `fk_RegistrationID` (`fk_RegistrationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_childregistration` (
  `childRegistrationID` int(10) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(80) DEFAULT NULL,
  `lastName` varchar(80) DEFAULT NULL,
  `gender` char(1) DEFAULT NULL,
  `age` int(10) DEFAULT NULL,
  `arriveDate` datetime DEFAULT NULL,
  `birthDate` datetime DEFAULT NULL,
  `leaveDate` datetime DEFAULT NULL,
  `inChildCare` char(1) DEFAULT NULL,
  `fk_RegistrationID` int(10) DEFAULT NULL,
  PRIMARY KEY (`childRegistrationID`),
  KEY `fk_RegistrationID` (`fk_RegistrationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_conference` (
  `conferenceID` int(10) NOT NULL AUTO_INCREMENT,
  `createDate` datetime DEFAULT NULL,
  `attributesAsked` varchar(30) DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `theme` varchar(128) DEFAULT NULL,
  `password` varchar(20) DEFAULT NULL,
  `staffPassword` varchar(20) DEFAULT NULL,
  `region` varchar(3) DEFAULT NULL,
  `briefDescription` varchar(8000) DEFAULT NULL,
  `contactName` varchar(60) DEFAULT NULL,
  `contactEmail` varchar(50) DEFAULT NULL,
  `contactPhone` varchar(24) DEFAULT NULL,
  `contactAddress1` varchar(35) DEFAULT NULL,
  `contactAddress2` varchar(35) DEFAULT NULL,
  `contactCity` varchar(30) DEFAULT NULL,
  `contactState` varchar(6) DEFAULT NULL,
  `contactZip` varchar(10) DEFAULT NULL,
  `splashPageURL` varchar(128) DEFAULT NULL,
  `confImageId` varchar(64) DEFAULT NULL,
  `fontFace` varchar(64) DEFAULT NULL,
  `backgroundColor` varchar(6) DEFAULT NULL,
  `foregroundColor` varchar(6) DEFAULT NULL,
  `highlightColor` varchar(6) DEFAULT NULL,
  `confirmationEmail` varchar(4000) DEFAULT NULL,
  `acceptCreditCards` char(1) DEFAULT NULL,
  `acceptEChecks` char(1) DEFAULT NULL,
  `acceptScholarships` char(1) DEFAULT NULL,
  `authnetPassword` varchar(200) DEFAULT NULL,
  `preRegStart` datetime DEFAULT NULL,
  `preRegEnd` datetime DEFAULT NULL,
  `defaultDateStaffArrive` datetime DEFAULT NULL,
  `defaultDateStaffLeave` datetime DEFAULT NULL,
  `defaultDateGuestArrive` datetime DEFAULT NULL,
  `defaultDateGuestLeave` datetime DEFAULT NULL,
  `defaultDateStudentArrive` datetime DEFAULT NULL,
  `defaultDateStudentLeave` datetime DEFAULT NULL,
  `masterDefaultDateArrive` datetime DEFAULT NULL,
  `masterDefaultDateLeave` datetime DEFAULT NULL,
  `ministryType` varchar(2) DEFAULT NULL,
  `isCloaked` varchar(1) DEFAULT NULL,
  `onsiteCost` double DEFAULT NULL,
  `commuterCost` double DEFAULT NULL,
  `preRegDeposit` double DEFAULT NULL,
  `discountFullPayment` double DEFAULT NULL,
  `discountEarlyReg` double DEFAULT NULL,
  `discountEarlyRegDate` datetime DEFAULT NULL,
  `checkPayableTo` varchar(40) DEFAULT NULL,
  `merchantAcctNum` varchar(64) DEFAULT NULL,
  `backgroundColor3` varchar(6) DEFAULT NULL,
  `backgroundColor2` varchar(6) DEFAULT NULL,
  `highlightColor2` varchar(6) DEFAULT NULL,
  `requiredColor` varchar(6) DEFAULT NULL,
  `acceptVisa` char(1) DEFAULT NULL,
  `acceptMasterCard` char(1) DEFAULT NULL,
  `acceptAmericanExpress` char(1) DEFAULT NULL,
  `acceptDiscover` char(1) DEFAULT NULL,
  `staffProfileNumber` int(10) DEFAULT NULL,
  `staffProfileReqNumber` int(10) DEFAULT NULL,
  `guestProfileNumber` int(10) DEFAULT NULL,
  `guestProfileReqNumber` int(10) DEFAULT NULL,
  `studentProfileNumber` int(10) DEFAULT NULL,
  `studentProfileReqNumber` int(10) DEFAULT NULL,
  `askStudentChildren` char(1) DEFAULT NULL,
  `askStaffChildren` char(1) DEFAULT NULL,
  `askGuestChildren` char(1) DEFAULT NULL,
  `studentLabel` varchar(64) DEFAULT NULL,
  `staffLabel` varchar(64) DEFAULT NULL,
  `guestLabel` varchar(64) DEFAULT NULL,
  `studentDesc` varchar(255) DEFAULT NULL,
  `staffDesc` varchar(255) DEFAULT NULL,
  `guestDesc` varchar(255) DEFAULT NULL,
  `askStudentSpouse` char(1) DEFAULT NULL,
  `askStaffSpouse` char(1) DEFAULT NULL,
  `askGuestSpouse` char(1) DEFAULT NULL,
  PRIMARY KEY (`conferenceID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_customitem` (
  `customItemID` int(10) NOT NULL AUTO_INCREMENT,
  `title` varchar(128) DEFAULT NULL,
  `text` varchar(1000) DEFAULT NULL,
  `displayOrder` int(10) DEFAULT NULL,
  `fk_ConferenceID` int(10) DEFAULT NULL,
  PRIMARY KEY (`customItemID`),
  KEY `fk_ConferenceID` (`fk_ConferenceID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_merchandise` (
  `merchandiseID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `amount` double DEFAULT NULL,
  `required` char(1) DEFAULT NULL,
  `registrationType` varchar(50) DEFAULT NULL,
  `displayOrder` int(10) DEFAULT NULL,
  `fk_ConferenceID` int(10) DEFAULT NULL,
  `fk_RegistrationTypeID` int(10) DEFAULT NULL,
  PRIMARY KEY (`merchandiseID`),
  KEY `fk_ConferenceID` (`fk_ConferenceID`,`fk_RegistrationTypeID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_merchandisechoice` (
  `fk_MerchandiseID` int(10) NOT NULL,
  `fk_RegistrationID` int(10) NOT NULL,
  PRIMARY KEY (`fk_MerchandiseID`,`fk_RegistrationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_payment` (
  `paymentID` int(10) NOT NULL AUTO_INCREMENT,
  `paymentDate` datetime DEFAULT NULL,
  `debit` double DEFAULT NULL,
  `credit` double DEFAULT NULL,
  `type` varchar(80) DEFAULT NULL,
  `authCode` varchar(80) DEFAULT NULL,
  `businessUnit` varchar(50) DEFAULT NULL,
  `dept` varchar(50) DEFAULT NULL,
  `operatingUnit` varchar(50) DEFAULT NULL,
  `project` varchar(50) DEFAULT NULL,
  `accountNo` varchar(80) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `posted` char(1) DEFAULT NULL,
  `postedDate` datetime DEFAULT NULL,
  `fk_RegistrationID` int(10) DEFAULT NULL,
  PRIMARY KEY (`paymentID`),
  KEY `fk_RegistrationID` (`fk_RegistrationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_question` (
  `questionID` int(10) NOT NULL AUTO_INCREMENT,
  `registrationType` varchar(50) DEFAULT NULL,
  `required` char(1) DEFAULT NULL,
  `displayOrder` int(10) DEFAULT NULL,
  `fk_ConferenceID` int(10) DEFAULT NULL,
  `fk_QuestionTextID` int(10) DEFAULT NULL,
  `fk_RegistrationTypeID` int(10) DEFAULT NULL,
  PRIMARY KEY (`questionID`),
  KEY `fk_ConferenceID` (`fk_ConferenceID`,`fk_RegistrationTypeID`),
  KEY `fk_QuestionTextID` (`fk_QuestionTextID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_questiontext` (
  `questionTextID` int(10) NOT NULL AUTO_INCREMENT,
  `body` varchar(7000) DEFAULT NULL,
  `answerType` varchar(50) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `oldID` int(10) DEFAULT NULL,
  PRIMARY KEY (`questionTextID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_registration` (
  `registrationID` int(10) NOT NULL AUTO_INCREMENT,
  `registrationDate` datetime DEFAULT NULL,
  `registrationType` varchar(80) DEFAULT NULL,
  `preRegistered` char(1) DEFAULT NULL,
  `newPersonID` int(10) DEFAULT NULL,
  `fk_ConferenceID` int(10) DEFAULT NULL,
  `arriveDate` datetime DEFAULT NULL,
  `leaveDate` datetime DEFAULT NULL,
  `additionalRooms` int(10) DEFAULT NULL,
  `spouseComing` int(10) DEFAULT NULL,
  `spouseRegistrationID` int(10) DEFAULT NULL,
  `registeredFirst` char(1) DEFAULT NULL,
  `isOnsite` char(1) DEFAULT NULL,
  `fk_RegistrationTypeID` int(10) DEFAULT NULL,
  `fk_PersonID` int(10) DEFAULT NULL,
  PRIMARY KEY (`registrationID`),
  KEY `fk_RegistrationTypeID` (`fk_RegistrationTypeID`),
  KEY `fk_PersonID` (`fk_PersonID`),
  KEY `fk_ConferenceID` (`fk_ConferenceID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_registrationtype` (
  `registrationTypeID` int(10) NOT NULL AUTO_INCREMENT,
  `label` varchar(64) DEFAULT NULL,
  `description` varchar(256) DEFAULT NULL,
  `defaultDateArrive` datetime DEFAULT NULL,
  `defaultDateLeave` datetime DEFAULT NULL,
  `preRegStart` datetime DEFAULT NULL,
  `preRegEnd` datetime DEFAULT NULL,
  `singlePreRegDeposit` double DEFAULT NULL,
  `singleOnsiteCost` double DEFAULT NULL,
  `singleCommuteCost` double DEFAULT NULL,
  `singleDiscountFullPayment` double DEFAULT NULL,
  `singleDiscountEarlyReg` double DEFAULT NULL,
  `singleDiscountEarlyRegDate` datetime DEFAULT NULL,
  `marriedPreRegDeposit` double DEFAULT NULL,
  `marriedOnsiteCost` double DEFAULT NULL,
  `marriedCommuteCost` double DEFAULT NULL,
  `marriedDiscountFullPayment` double DEFAULT NULL,
  `marriedDiscountEarlyReg` double DEFAULT NULL,
  `marriedDiscountEarlyRegDate` datetime DEFAULT NULL,
  `acceptEChecks` char(1) DEFAULT NULL,
  `acceptScholarships` char(1) DEFAULT NULL,
  `acceptStaffAcctTransfer` char(1) DEFAULT NULL,
  `acceptMinistryAcctTransfer` char(1) DEFAULT NULL,
  `acceptCreditCards` char(1) DEFAULT NULL,
  `askChildren` char(1) DEFAULT NULL,
  `askSpouse` char(1) DEFAULT NULL,
  `askChildCare` varchar(1) DEFAULT NULL,
  `askAdditionalRooms` varchar(1) DEFAULT NULL,
  `allowCommute` char(1) DEFAULT NULL,
  `displayOrder` smallint(5) DEFAULT NULL,
  `profileNumber` int(10) DEFAULT NULL,
  `profileReqNumber` int(10) DEFAULT NULL,
  `registrationType` varchar(10) DEFAULT NULL,
  `fk_ConferenceID` int(10) DEFAULT NULL,
  `acceptChecks` char(1) DEFAULT NULL,
  PRIMARY KEY (`registrationTypeID`),
  KEY `fk_ConferenceID` (`fk_ConferenceID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crs_report` (
  `reportID` int(10) NOT NULL AUTO_INCREMENT,
  `query` varchar(1000) DEFAULT NULL,
  `xsl` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `reportGroup` int(10) DEFAULT NULL,
  `sorts` varchar(1000) DEFAULT NULL,
  `sortNames` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`reportID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `email_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_email_addresses_on_person_id_and_email` (`person_id`,`email`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=latin1;

CREATE TABLE `engine_schema_info` (
  `engine_name` varchar(255) DEFAULT NULL,
  `version` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `followup_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `commenter_id` int(11) DEFAULT NULL,
  `comment` text,
  `status` varchar(255) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comment_organization_id_contact_id` (`organization_id`,`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_allocations` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `ssm_id` int(10) DEFAULT NULL,
  `region_id` int(10) DEFAULT NULL,
  `impact_allotment` int(10) DEFAULT NULL,
  `forerunner_allotment` int(10) DEFAULT NULL,
  `regional_allotment` int(10) DEFAULT NULL,
  `regionally_raised` int(10) DEFAULT NULL,
  `locally_raised` int(10) DEFAULT NULL,
  `allocation_year` varchar(10) DEFAULT NULL,
  `national_notes` longtext,
  `impact_notes` longtext,
  `forerunner_notes` longtext,
  `regional_notes` longtext,
  `local_notes` longtext,
  `lock_version` int(10) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `agree_to_report` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_fsk_allocations_simplesecuritymanager_user` (`ssm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_fields` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_fields_roles` (
  `role_id` int(10) NOT NULL,
  `field_id` int(10) NOT NULL,
  PRIMARY KEY (`role_id`,`field_id`),
  KEY `FK_fsk_fields_roles` (`field_id`),
  CONSTRAINT `fsk_fields_roles_ibfk_1` FOREIGN KEY (`field_id`) REFERENCES `fsk_fields` (`id`),
  CONSTRAINT `fsk_fields_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `fsk_roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_kit_categories` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(2000) DEFAULT NULL,
  `lock_version` int(10) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_line_items` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `product_id` int(10) NOT NULL DEFAULT '0',
  `order_id` int(10) NOT NULL DEFAULT '0',
  `quantity` int(10) NOT NULL DEFAULT '0',
  `lock_version` int(10) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_fsk_line_items_fsk_orders` (`order_id`),
  KEY `FK_fsk_line_items_fsk_products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_orders` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `location_name` varchar(128) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `allocation_id` int(10) DEFAULT NULL,
  `contact_first_name` varchar(30) DEFAULT NULL,
  `contact_last_name` varchar(30) DEFAULT NULL,
  `contact_phone` varchar(24) DEFAULT NULL,
  `contact_cell` varchar(24) DEFAULT NULL,
  `contact_email` varchar(50) DEFAULT NULL,
  `ship_first_name` varchar(30) DEFAULT NULL,
  `ship_address1` varchar(50) DEFAULT NULL,
  `ship_address2` varchar(50) DEFAULT NULL,
  `ship_city` varchar(30) DEFAULT NULL,
  `ship_state` varchar(6) DEFAULT NULL,
  `ship_zip` varchar(10) DEFAULT NULL,
  `ship_phone` varchar(24) DEFAULT NULL,
  `total_kits` int(10) DEFAULT NULL,
  `business_unit` varchar(20) DEFAULT NULL,
  `operating_unit` varchar(20) DEFAULT NULL,
  `dept_id` varchar(20) DEFAULT NULL,
  `project_id` varchar(10) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `order_year` varchar(10) DEFAULT NULL,
  `ssm_id` int(10) DEFAULT NULL,
  `lock_version` int(10) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `ship_last_name` varchar(255) DEFAULT NULL,
  `freeze_order` tinyint(1) DEFAULT '0',
  `target_audience` longtext,
  `how_used` longtext,
  PRIMARY KEY (`id`),
  KEY `FK_fsk_orders_simplesecuritymanager_user` (`ssm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_products` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '',
  `description` longtext,
  `image_filename` varchar(1000) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `quantity` int(10) NOT NULL DEFAULT '0',
  `lock_version` int(10) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `kit_category_id` int(10) DEFAULT NULL,
  `availability` varchar(20) NOT NULL DEFAULT 'both',
  `box_quantity` int(11) DEFAULT '100',
  PRIMARY KEY (`id`),
  KEY `FK_fsk_products_fsk_kit_categories` (`kit_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_roles` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fsk_users` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `role_id` int(10) NOT NULL DEFAULT '0',
  `ssm_id` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_fsk_users_simplesecuritymanager_user` (`ssm_id`),
  KEY `FK_fsk_users_fsk_roles` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hr_ms_payment` (
  `paymentID` int(10) NOT NULL AUTO_INCREMENT,
  `paymentDate` datetime DEFAULT NULL,
  `debit` double DEFAULT NULL,
  `credit` double DEFAULT NULL,
  `type` varchar(80) DEFAULT NULL,
  `authCode` varchar(80) DEFAULT NULL,
  `businessUnit` varchar(50) DEFAULT NULL,
  `dept` varchar(50) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `project` varchar(50) DEFAULT NULL,
  `accountNo` varchar(80) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `posted` tinyint(1) DEFAULT NULL,
  `postedDate` datetime DEFAULT NULL,
  `fk_WsnApplicationID` int(10) DEFAULT NULL,
  `paymentFor` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`paymentID`),
  KEY `fk_WsnApplicationID` (`fk_WsnApplicationID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hr_review360_review360` (
  `Review360ID` int(10) NOT NULL AUTO_INCREMENT,
  `reviewedByID` varchar(64) DEFAULT NULL,
  `dateStarted` datetime DEFAULT NULL,
  `dateCompleted` datetime DEFAULT NULL,
  `dateDue` datetime DEFAULT NULL,
  `currentPosition` varchar(128) DEFAULT NULL,
  `leadershipLevel` varchar(128) DEFAULT NULL,
  `relationship` varchar(128) DEFAULT NULL,
  `q1` mediumtext,
  `q2` int(10) DEFAULT NULL,
  `q3` mediumtext,
  `q4` mediumtext,
  `q5` mediumtext,
  `q6` mediumtext,
  `q7` mediumtext,
  `q8` int(10) DEFAULT NULL,
  `q9` mediumtext,
  `q10` int(10) DEFAULT NULL,
  `q11` mediumtext,
  `q12` int(10) DEFAULT NULL,
  `q13` mediumtext,
  `q14` int(10) DEFAULT NULL,
  `q15` mediumtext,
  `q16` int(10) DEFAULT NULL,
  `q17` mediumtext,
  `q18` int(10) DEFAULT NULL,
  `q19` mediumtext,
  `q20` int(10) DEFAULT NULL,
  `q21` mediumtext,
  `q22` int(10) DEFAULT NULL,
  `q23` mediumtext,
  `q24` int(10) DEFAULT NULL,
  `q25` mediumtext,
  `q26` mediumtext,
  `q27` mediumtext,
  `q28f1` mediumtext,
  `q28f2` int(10) DEFAULT NULL,
  `q28l1` mediumtext,
  `q28l2` int(10) DEFAULT NULL,
  `q28o1` mediumtext,
  `q28o2` int(10) DEFAULT NULL,
  `q28a1` mediumtext,
  `q28a2` int(10) DEFAULT NULL,
  `q28t1` mediumtext,
  `q28t2` int(10) DEFAULT NULL,
  `q28s1` mediumtext,
  `q28s2` int(10) DEFAULT NULL,
  `q29` mediumtext,
  `q30` mediumtext,
  `q31` mediumtext,
  `q32` mediumtext,
  `q33` mediumtext,
  `q34` mediumtext,
  `fk_ReviewSessionID` int(10) DEFAULT NULL,
  `reviewedByTitle` varchar(5) DEFAULT NULL,
  `reviewedByFirstName` varchar(30) DEFAULT NULL,
  `reviewedByLastName` varchar(30) DEFAULT NULL,
  `reviewedByEmail` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`Review360ID`),
  KEY `index1` (`fk_ReviewSessionID`)
) ENGINE=MyISAM AUTO_INCREMENT=11826 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='InnoDB free: 9216 kB';

CREATE TABLE `hr_review360_review360light` (
  `Review360LightID` int(10) NOT NULL AUTO_INCREMENT,
  `reviewedByID` varchar(64) DEFAULT NULL,
  `reviewedByTitle` varchar(5) DEFAULT NULL,
  `reviewedByFirstName` varchar(30) DEFAULT NULL,
  `reviewedByLastName` varchar(30) DEFAULT NULL,
  `reviewedByEmail` varchar(50) DEFAULT NULL,
  `dateStarted` datetime DEFAULT NULL,
  `dateCompleted` datetime DEFAULT NULL,
  `dateDue` datetime DEFAULT NULL,
  `currentPosition` varchar(128) DEFAULT NULL,
  `leadershipLevel` varchar(128) DEFAULT NULL,
  `relationship` varchar(128) DEFAULT NULL,
  `q1` mediumtext,
  `q2` mediumtext,
  `q3` mediumtext,
  `q4` mediumtext,
  `q5` mediumtext,
  `q6` mediumtext,
  `q7` mediumtext,
  `q8` mediumtext,
  `q9` mediumtext,
  `fk_ReviewSessionLightID` int(10) DEFAULT NULL,
  PRIMARY KEY (`Review360LightID`),
  KEY `index1` (`fk_ReviewSessionLightID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hr_review360_reviewsession` (
  `ReviewSessionID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `dateDue` datetime DEFAULT NULL,
  `dateStarted` datetime DEFAULT NULL,
  `revieweeID` varchar(128) DEFAULT NULL,
  `administratorID` varchar(128) DEFAULT NULL,
  `requestedByID` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`ReviewSessionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hr_review360_reviewsessionlight` (
  `ReviewSessionLightID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  `purpose` varchar(255) DEFAULT NULL,
  `dateDue` datetime DEFAULT NULL,
  `dateStarted` datetime DEFAULT NULL,
  `revieweeID` varchar(128) DEFAULT NULL,
  `administratorID` varchar(128) DEFAULT NULL,
  `requestedByID` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`ReviewSessionLightID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hr_si_applications` (
  `applicationID` int(10) NOT NULL AUTO_INCREMENT,
  `oldApplicationID` int(10) unsigned DEFAULT NULL,
  `locationA` int(11) unsigned DEFAULT NULL,
  `locationAExplanation` varchar(90) DEFAULT NULL,
  `locationB` int(11) unsigned DEFAULT NULL,
  `locationBExplanation` varchar(90) DEFAULT NULL,
  `locationC` int(11) unsigned DEFAULT NULL,
  `locationCExplanation` varchar(90) DEFAULT NULL,
  `availableMonth` varchar(2) DEFAULT NULL,
  `availableYear` varchar(4) DEFAULT NULL,
  `hasMinistryConflict` int(10) DEFAULT NULL,
  `ministryConflictExplanation` longtext,
  `hasSpecificLocation` int(10) DEFAULT NULL,
  `specificLocationRecruiterName` varchar(50) DEFAULT NULL,
  `teamMembers` longtext,
  `isDating` int(10) DEFAULT NULL,
  `datingLocation` longtext,
  `hasCampusPartnership` int(10) DEFAULT NULL,
  `isDatingStint` int(10) DEFAULT NULL,
  `datingStintName` longtext,
  `language1` varchar(50) DEFAULT NULL,
  `language1YearsStudied` varchar(20) DEFAULT NULL,
  `language1Fluency` int(10) DEFAULT NULL,
  `language2` varchar(50) DEFAULT NULL,
  `language2YearsStudied` varchar(20) DEFAULT NULL,
  `language2Fluency` int(10) DEFAULT NULL,
  `previousMinistryExperience` longtext,
  `ministryTraining` longtext,
  `evangelismAttitude` longtext,
  `isEvangelismTrainable` int(10) DEFAULT NULL,
  `participationExplanation` longtext,
  `isFamiliarFourSpiritualLaws` int(10) DEFAULT NULL,
  `hasExperienceFourSpiritualLaws` int(10) DEFAULT NULL,
  `confidenceFourSpiritualLaws` int(10) DEFAULT NULL,
  `isFamiliarLifeAtLarge` int(10) DEFAULT NULL,
  `hasExperienceLifeAtLarge` int(10) DEFAULT NULL,
  `confidenceLifeAtLarge` int(10) DEFAULT NULL,
  `isFamiliarPersonalTestimony` int(10) DEFAULT NULL,
  `hasExperiencePersonalTestimony` int(10) DEFAULT NULL,
  `confidencePersonalTestimony` int(10) DEFAULT NULL,
  `isFamiliarExplainingGospel` int(10) DEFAULT NULL,
  `hasExperienceExplainingGospel` int(10) DEFAULT NULL,
  `confidenceExplainingGospel` int(10) DEFAULT NULL,
  `isFamiliarSharingFaith` int(10) DEFAULT NULL,
  `hasExperienceSharingFaith` int(10) DEFAULT NULL,
  `confidenceSharingFaith` int(10) DEFAULT NULL,
  `isFamiliarHolySpiritBooklet` int(10) DEFAULT NULL,
  `hasExperienceHolySpiritBooklet` int(10) DEFAULT NULL,
  `confidenceHolySpiritBooklet` int(10) DEFAULT NULL,
  `isFamiliarFollowUp` int(10) DEFAULT NULL,
  `hasExperienceFollowUp` int(10) DEFAULT NULL,
  `confidenceFollowUp` int(10) DEFAULT NULL,
  `isFamiliarHelpGrowInFaith` int(10) DEFAULT NULL,
  `hasExperienceHelpGrowInFaith` int(10) DEFAULT NULL,
  `confidenceHelpGrowInFaith` int(10) DEFAULT NULL,
  `isFamiliarTrainShareFaith` int(10) DEFAULT NULL,
  `hasExperienceTrainShareFaith` int(10) DEFAULT NULL,
  `confidenceTrainShareFaith` int(10) DEFAULT NULL,
  `isFamiliarOtherReligions` int(10) DEFAULT NULL,
  `hasExperienceOtherReligions` int(10) DEFAULT NULL,
  `confidenceOtherReligions` int(10) DEFAULT NULL,
  `leadershipPositions` longtext,
  `hasLedDiscipleshipGroup` int(10) DEFAULT NULL,
  `discipleshipGroupSize` varchar(50) DEFAULT NULL,
  `leadershipEvaluation` longtext,
  `conversionMonth` int(10) DEFAULT NULL,
  `conversionYear` int(10) DEFAULT NULL,
  `memberChurchDenomination` varchar(75) DEFAULT NULL,
  `memberChurchDuration` varchar(50) DEFAULT NULL,
  `attendingChurchDenomination` varchar(50) DEFAULT NULL,
  `attendingChurchDuration` varchar(50) DEFAULT NULL,
  `attendingChurchInvolvement` longtext,
  `quietTimeQuantity` longtext,
  `quietTimeDescription` longtext,
  `explanationOfSalvation` longtext,
  `explanationOfSpiritFilled` longtext,
  `hasInvolvementSpeakingTongues` int(10) DEFAULT NULL,
  `differenceIndwellingFilled` longtext,
  `hasCrimeConviction` int(10) DEFAULT NULL,
  `crimeConvictionExplanation` longtext,
  `hasDrugUse` int(10) DEFAULT NULL,
  `isTobaccoUser` int(10) DEFAULT NULL,
  `isWillingChangeHabits` int(10) DEFAULT NULL,
  `authorityResponseExplanation` longtext,
  `alcoholUseFrequency` longtext,
  `alcoholUseDecision` longtext,
  `isWillingRefrainAlcohol` int(10) DEFAULT NULL,
  `unwillingRefrainAlcoholExplanation` longtext,
  `drugUseExplanation` longtext,
  `tobaccoUseExplanation` longtext,
  `isWillingAbstainTobacco` int(10) DEFAULT NULL,
  `hasRequestedPhoneCall` int(10) DEFAULT NULL,
  `contactPhoneNumber` varchar(50) DEFAULT NULL,
  `contactBestTime` varchar(50) DEFAULT NULL,
  `contactTimeZone` varchar(50) DEFAULT NULL,
  `sexualInvolvementExplanation` longtext,
  `hasSexualGuidelines` int(10) DEFAULT NULL,
  `sexualGuidelineExplanation` longtext,
  `isCurrentlyDating` int(10) DEFAULT NULL,
  `currentlyDatingLocation` longtext,
  `hasHomosexualInvolvement` int(10) DEFAULT NULL,
  `homosexualInvolvementExplanation` longtext,
  `hasRecentPornographicInvolvement` int(10) DEFAULT NULL,
  `pornographicInvolvementMonth` int(10) DEFAULT NULL,
  `pornographicInvolvementYear` int(10) DEFAULT NULL,
  `pornographicInvolvementExplanation` longtext,
  `hasRecentSexualImmorality` int(10) DEFAULT NULL,
  `sexualImmoralityMonth` int(10) DEFAULT NULL,
  `sexualImmoralityYear` int(10) DEFAULT NULL,
  `sexualImmoralityExplanation` longtext,
  `hasOtherDateSinceImmorality` int(10) DEFAULT NULL,
  `singleImmoralityResultsExplanation` longtext,
  `marriedImmoralityResultsExplanation` longtext,
  `immoralityLifeChangeExplanation` longtext,
  `immoralityCurrentStrugglesExplanation` longtext,
  `additionalMoralComments` longtext,
  `isAwareMustRaiseSupport` int(10) DEFAULT NULL,
  `isInDebt` int(10) DEFAULT NULL,
  `debtNature1` varchar(50) DEFAULT NULL,
  `debtTotal1` varchar(50) DEFAULT NULL,
  `debtMonthlyPayment1` varchar(50) DEFAULT NULL,
  `debtNature2` varchar(50) DEFAULT NULL,
  `debtTotal2` varchar(50) DEFAULT NULL,
  `debtMonthlyPayment2` varchar(50) DEFAULT NULL,
  `debtNature3` varchar(50) DEFAULT NULL,
  `debtTotal3` varchar(50) DEFAULT NULL,
  `debtMonthlyPayment3` varchar(50) DEFAULT NULL,
  `hasOtherFinancialResponsibility` int(10) DEFAULT NULL,
  `otherFinancialResponsibilityExplanation` longtext,
  `debtPaymentPlan` longtext,
  `debtPaymentTimeframe` longtext,
  `developingPartnersExplanation` longtext,
  `isWillingDevelopPartners` int(10) DEFAULT NULL,
  `unwillingDevelopPartnersExplanation` longtext,
  `isCommittedDevelopPartners` int(10) DEFAULT NULL,
  `uncommittedDevelopPartnersExplanation` longtext,
  `personalTestimonyGrowth` longtext,
  `internshipParticipationExplanation` longtext,
  `internshipObjectives` longtext,
  `currentMinistryDescription` longtext,
  `personalStrengthA` longtext,
  `personalStrengthB` longtext,
  `personalStrengthC` longtext,
  `personalDevelopmentA` longtext,
  `personalDevelopmentB` longtext,
  `personalDevelopmentC` longtext,
  `personalDescriptionA` longtext,
  `personalDescriptionB` longtext,
  `personalDescriptionC` longtext,
  `familyRelationshipDescription` longtext,
  `electronicSignature` varchar(90) DEFAULT NULL,
  `ssn` varchar(50) DEFAULT NULL,
  `fk_ssmUserID` int(10) DEFAULT NULL,
  `fk_personID` int(11) unsigned NOT NULL,
  `isPaid` tinyint(1) DEFAULT NULL,
  `appFee` decimal(18,0) DEFAULT NULL,
  `dateAppLastChanged` datetime DEFAULT NULL,
  `dateAppStarted` datetime DEFAULT NULL,
  `dateSubmitted` datetime DEFAULT NULL,
  `isSubmitted` tinyint(1) DEFAULT NULL,
  `appStatus` varchar(15) DEFAULT NULL,
  `assignedToProject` int(10) DEFAULT NULL,
  `finalProject` decimal(10,0) DEFAULT NULL,
  `siYear` varchar(50) DEFAULT NULL,
  `submitDate` datetime DEFAULT NULL,
  `status` varchar(22) DEFAULT NULL,
  `appType` varchar(64) DEFAULT NULL,
  `apply_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`applicationID`),
  KEY `fk_PersonID` (`fk_personID`),
  KEY `oldApplicationID` (`oldApplicationID`),
  KEY `apply_id` (`apply_id`),
  KEY `siYear` (`siYear`),
  KEY `locationA` (`locationA`),
  KEY `locationB` (`locationB`),
  KEY `locationC` (`locationC`)
) ENGINE=MyISAM AUTO_INCREMENT=11285 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='InnoDB free: 532480 kB';

CREATE TABLE `hr_si_payment` (
  `paymentID` int(10) NOT NULL AUTO_INCREMENT,
  `paymentDate` datetime DEFAULT NULL,
  `debit` double DEFAULT NULL,
  `credit` double DEFAULT NULL,
  `type` varchar(80) DEFAULT NULL,
  `authCode` varchar(80) DEFAULT NULL,
  `businessUnit` varchar(50) DEFAULT NULL,
  `dept` varchar(50) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `project` varchar(50) DEFAULT NULL,
  `accountNo` varchar(80) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `posted` char(1) DEFAULT NULL,
  `postedDate` datetime DEFAULT NULL,
  `fk_ApplicationID` int(10) DEFAULT NULL,
  `paymentFor` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`paymentID`),
  KEY `fk_ApplicationID` (`fk_ApplicationID`)
) ENGINE=InnoDB AUTO_INCREMENT=3347 DEFAULT CHARSET=utf8;

CREATE TABLE `hr_si_project` (
  `SIProjectID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `partnershipRegion` varchar(50) DEFAULT NULL,
  `history` varchar(8000) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `details` varchar(8000) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `destinationGatewayCity` varchar(255) DEFAULT NULL,
  `departDateFromGateCity` datetime DEFAULT NULL,
  `arrivalDateAtLocation` datetime DEFAULT NULL,
  `locationGatewayCity` varchar(255) DEFAULT NULL,
  `departDateFromLocation` datetime DEFAULT NULL,
  `arrivalDateAtGatewayCity` datetime DEFAULT NULL,
  `flightBudget` int(10) DEFAULT NULL,
  `gatewayCitytoLocationFlightNo` varchar(255) DEFAULT NULL,
  `locationToGatewayCityFlightNo` varchar(255) DEFAULT NULL,
  `inCountryContact` varchar(255) DEFAULT NULL,
  `scholarshipAccountNo` varchar(255) DEFAULT NULL,
  `operatingAccountNo` varchar(255) DEFAULT NULL,
  `AOA` varchar(255) DEFAULT NULL,
  `MPTA` varchar(255) DEFAULT NULL,
  `staffCost` int(10) DEFAULT NULL,
  `studentCost` int(10) DEFAULT NULL,
  `studentCostExplaination` text,
  `insuranceFormsReceived` tinyint(1) DEFAULT NULL,
  `CAPSFeePaid` tinyint(1) DEFAULT NULL,
  `adminFeePaid` tinyint(1) DEFAULT NULL,
  `storiesXX` varchar(255) DEFAULT NULL,
  `stats` varchar(255) DEFAULT NULL,
  `secure` tinyint(1) DEFAULT NULL,
  `projEvalCompleted` tinyint(1) DEFAULT NULL,
  `evangelisticExposures` int(10) DEFAULT NULL,
  `receivedChrist` int(10) DEFAULT NULL,
  `jesusFilmExposures` int(10) DEFAULT NULL,
  `jesusFilmReveivedChrist` int(10) DEFAULT NULL,
  `coverageActivitiesExposures` int(10) DEFAULT NULL,
  `coverageActivitiesDecisions` int(10) DEFAULT NULL,
  `holySpiritDecisions` int(10) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `destinationAddress` varchar(255) DEFAULT NULL,
  `destinationPhone` varchar(255) DEFAULT NULL,
  `siYear` varchar(255) DEFAULT NULL,
  `fk_isCoord` int(11) DEFAULT NULL,
  `fk_isAPD` int(11) DEFAULT NULL,
  `fk_isPD` int(11) DEFAULT NULL,
  `projectType` char(1) DEFAULT NULL,
  `studentStartDate` datetime DEFAULT NULL,
  `studentEndDate` datetime DEFAULT NULL,
  `staffStartDate` datetime DEFAULT NULL,
  `staffEndDate` datetime DEFAULT NULL,
  `leadershipStartDate` datetime DEFAULT NULL,
  `leadershipEndDate` datetime DEFAULT NULL,
  `createDate` datetime DEFAULT NULL,
  `lastChangedDate` binary(8) DEFAULT NULL,
  `lastChangedBy` int(11) DEFAULT NULL,
  `displayLocation` varchar(255) DEFAULT NULL,
  `partnershipRegionOnly` tinyint(1) DEFAULT NULL,
  `internCost` int(10) DEFAULT NULL,
  `onHold` tinyint(1) DEFAULT NULL,
  `maxNoStaffPMale` int(10) DEFAULT NULL,
  `maxNoStaffPFemale` int(10) DEFAULT NULL,
  `maxNoStaffPCouples` int(10) DEFAULT NULL,
  `maxNoStaffPFamilies` int(10) DEFAULT NULL,
  `maxNoStaffP` int(10) DEFAULT NULL,
  `maxNoInternAMale` int(10) DEFAULT NULL,
  `maxNoInternAFemale` int(10) DEFAULT NULL,
  `maxNoInternACouples` int(10) DEFAULT NULL,
  `maxNoInternAFamilies` int(10) DEFAULT NULL,
  `maxNoInternA` int(10) DEFAULT NULL,
  `maxNoInternPMale` int(10) DEFAULT NULL,
  `maxNoInternPFemale` int(10) DEFAULT NULL,
  `maxNoInternPCouples` int(10) DEFAULT NULL,
  `maxNoInternPFamilies` int(10) DEFAULT NULL,
  `maxNoInternP` int(10) DEFAULT NULL,
  `maxNoStudentAMale` int(10) DEFAULT NULL,
  `maxNoStudentAFemale` int(10) DEFAULT NULL,
  `maxNoStudentACouples` int(10) DEFAULT NULL,
  `maxNoStudentAFamilies` int(10) DEFAULT NULL,
  `maxNoStudentA` int(10) DEFAULT NULL,
  `maxNoStudentPMale` int(10) DEFAULT NULL,
  `maxNoStudentPFemale` int(10) DEFAULT NULL,
  `maxNoStudentPCouples` int(10) DEFAULT NULL,
  `maxNoStudentPFamilies` int(10) DEFAULT NULL,
  `maxNoStudentP` int(10) DEFAULT NULL,
  PRIMARY KEY (`SIProjectID`)
) ENGINE=InnoDB AUTO_INCREMENT=2415 DEFAULT CHARSET=utf8;

CREATE TABLE `hr_si_reference` (
  `referenceID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `oldReferenceID` int(11) unsigned DEFAULT NULL,
  `formWorkflowStatus` varchar(1) DEFAULT NULL,
  `createDate` datetime DEFAULT NULL,
  `lastChangedDate` datetime DEFAULT NULL,
  `lastChangedBy` varchar(30) DEFAULT NULL,
  `isFormSubmitted` tinyint(1) DEFAULT NULL,
  `formSubmittedDate` datetime DEFAULT NULL,
  `referenceType` varchar(2) DEFAULT NULL,
  `title` varchar(5) DEFAULT NULL,
  `firstName` varchar(30) DEFAULT NULL,
  `lastName` varchar(30) DEFAULT NULL,
  `isStaff` tinyint(1) DEFAULT NULL,
  `staffNumber` varchar(16) DEFAULT NULL,
  `currentAddress1` varchar(35) DEFAULT NULL,
  `currentAddress2` varchar(35) DEFAULT NULL,
  `currentCity` varchar(35) DEFAULT NULL,
  `currentState` varchar(6) DEFAULT NULL,
  `currentZip` varchar(10) DEFAULT NULL,
  `cellPhone` varchar(24) DEFAULT NULL,
  `homePhone` varchar(24) DEFAULT NULL,
  `workPhone` varchar(24) DEFAULT NULL,
  `currentEmail` varchar(50) DEFAULT NULL,
  `howKnown` varchar(64) DEFAULT NULL,
  `howLongKnown` varchar(64) DEFAULT NULL,
  `howWellKnown` int(10) DEFAULT NULL,
  `howWellComm` int(10) DEFAULT NULL,
  `_rg1` int(10) DEFAULT NULL,
  `_rg2` int(10) DEFAULT NULL,
  `_rg3` int(10) DEFAULT NULL,
  `_rg4` int(10) DEFAULT NULL,
  `_rg5` int(10) DEFAULT NULL,
  `_rg1c` varchar(50) DEFAULT NULL,
  `_rg2c` varchar(50) DEFAULT NULL,
  `_rg3c` varchar(50) DEFAULT NULL,
  `_rg4c` varchar(50) DEFAULT NULL,
  `_rg5c` varchar(50) DEFAULT NULL,
  `_rg6` varchar(8000) DEFAULT NULL,
  `_rg7` tinyint(1) DEFAULT NULL,
  `_rg8` longtext,
  `_rg9` longtext,
  `_ro1` int(10) DEFAULT NULL,
  `_ro2` int(10) DEFAULT NULL,
  `_ro3` int(10) DEFAULT NULL,
  `_ro4` int(10) DEFAULT NULL,
  `_ro5` int(10) DEFAULT NULL,
  `_ro6` int(10) DEFAULT NULL,
  `_ro7` int(10) DEFAULT NULL,
  `_ro1c` varchar(50) DEFAULT NULL,
  `_ro2c` varchar(50) DEFAULT NULL,
  `_ro3c` varchar(50) DEFAULT NULL,
  `_ro4c` varchar(50) DEFAULT NULL,
  `_ro5c` varchar(50) DEFAULT NULL,
  `_ro6c` varchar(50) DEFAULT NULL,
  `_ro7c` varchar(50) DEFAULT NULL,
  `_ro8` longtext,
  `_ro9` longtext,
  `_ro10` longtext,
  `_dd1` int(10) DEFAULT NULL,
  `_dd2` int(10) DEFAULT NULL,
  `_dd3` int(10) DEFAULT NULL,
  `_dd4` int(10) DEFAULT NULL,
  `_dd1c` varchar(50) DEFAULT NULL,
  `_dd2c` varchar(50) DEFAULT NULL,
  `_dd3c` varchar(50) DEFAULT NULL,
  `_dd4c` varchar(50) DEFAULT NULL,
  `_dd5` longtext,
  `_dd6` longtext,
  `_if1` int(10) DEFAULT NULL,
  `_if2` int(10) DEFAULT NULL,
  `_if3` int(10) DEFAULT NULL,
  `_if4` int(10) DEFAULT NULL,
  `_if1c` varchar(50) DEFAULT NULL,
  `_if2c` varchar(50) DEFAULT NULL,
  `_if3c` varchar(50) DEFAULT NULL,
  `_if4c` varchar(50) DEFAULT NULL,
  `_if5` longtext,
  `_if6` longtext,
  `_ch1` int(10) DEFAULT NULL,
  `_ch2` int(10) DEFAULT NULL,
  `_ch3` int(10) DEFAULT NULL,
  `_ch4` int(10) DEFAULT NULL,
  `_ch5` int(10) DEFAULT NULL,
  `_ch1c` varchar(50) DEFAULT NULL,
  `_ch2c` varchar(50) DEFAULT NULL,
  `_ch3c` varchar(50) DEFAULT NULL,
  `_ch4c` varchar(50) DEFAULT NULL,
  `_ch5c` varchar(50) DEFAULT NULL,
  `_ch6` longtext,
  `_ch7` longtext,
  `_ch8` longtext,
  `_ew1` int(10) DEFAULT NULL,
  `_ew2` int(10) DEFAULT NULL,
  `_ew3` int(10) DEFAULT NULL,
  `_ew4` int(10) DEFAULT NULL,
  `_ew5` int(10) DEFAULT NULL,
  `_ew1c` varchar(50) DEFAULT NULL,
  `_ew2c` varchar(50) DEFAULT NULL,
  `_ew3c` varchar(50) DEFAULT NULL,
  `_ew4c` varchar(50) DEFAULT NULL,
  `_ew5c` varchar(50) DEFAULT NULL,
  `_ew6` longtext,
  `_ew7` tinyint(1) DEFAULT NULL,
  `_ew8` longtext,
  `_ew9` tinyint(1) DEFAULT NULL,
  `_ew10` longtext,
  `_ms1` int(10) DEFAULT NULL,
  `_ms2` int(10) DEFAULT NULL,
  `_ms3` int(10) DEFAULT NULL,
  `_ms4` int(10) DEFAULT NULL,
  `_ms1c` varchar(50) DEFAULT NULL,
  `_ms2c` varchar(50) DEFAULT NULL,
  `_ms3c` varchar(50) DEFAULT NULL,
  `_ms4c` varchar(50) DEFAULT NULL,
  `_ms5` longtext,
  `_ls1` int(10) DEFAULT NULL,
  `_ls2` int(10) DEFAULT NULL,
  `_ls3` int(10) DEFAULT NULL,
  `_ls4` int(10) DEFAULT NULL,
  `_ls5` int(10) DEFAULT NULL,
  `_ls1c` varchar(50) DEFAULT NULL,
  `_ls2c` varchar(50) DEFAULT NULL,
  `_ls3c` varchar(50) DEFAULT NULL,
  `_ls4c` varchar(50) DEFAULT NULL,
  `_ls5c` varchar(50) DEFAULT NULL,
  `_ls6` longtext,
  `_ls7` longtext,
  `_ls8` longtext,
  `_re1` longtext,
  `_re2` longtext,
  `_re3` longtext,
  `_re4` int(10) DEFAULT NULL,
  `_re5` longtext,
  `oldSIApplicationID` int(11) unsigned DEFAULT NULL,
  `fk_SIApplicationID` int(10) unsigned DEFAULT NULL,
  `siYear` char(4) DEFAULT NULL,
  PRIMARY KEY (`referenceID`),
  KEY `IX_hr_si_Reference_2006` (`oldSIApplicationID`),
  KEY `oldReferenceID` (`oldReferenceID`),
  KEY `fk_SIApplicationID` (`fk_SIApplicationID`),
  KEY `siYear` (`siYear`)
) ENGINE=MyISAM AUTO_INCREMENT=24551 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='InnoDB free: 532480 kB';

CREATE TABLE `hr_si_users` (
  `siUserID` int(10) NOT NULL AUTO_INCREMENT,
  `fk_ssmUserID` int(10) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `expirationDate` datetime DEFAULT NULL,
  PRIMARY KEY (`siUserID`),
  KEY `IX_hr_si_Users_fk_ssmUserID` (`fk_ssmUserID`)
) ENGINE=InnoDB AUTO_INCREMENT=463 DEFAULT CHARSET=utf8;

CREATE TABLE `lat_long_by_zip_code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zip` varchar(255) DEFAULT NULL,
  `lat` decimal(15,10) DEFAULT NULL,
  `long` decimal(15,10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `linczone_contacts` (
  `ContactID` int(10) NOT NULL AUTO_INCREMENT,
  `EntryDate` timestamp NULL DEFAULT NULL,
  `FirstName` varchar(120) DEFAULT NULL,
  `LastName` varchar(120) DEFAULT NULL,
  `HomeAddress` varchar(200) DEFAULT NULL,
  `City` varchar(20) DEFAULT NULL,
  `State` varchar(20) DEFAULT NULL,
  `Zip` varchar(80) DEFAULT NULL,
  `Email` varchar(120) DEFAULT NULL,
  `HighSchool` varchar(120) DEFAULT NULL,
  `CampusName` varchar(200) DEFAULT NULL,
  `CampusID` varchar(80) DEFAULT NULL,
  `ReferrerFirstName` varchar(120) DEFAULT NULL,
  `ReferrerLastName` varchar(120) DEFAULT NULL,
  `ReferrerRelationship` varchar(100) DEFAULT NULL,
  `ReferrerEmail` varchar(200) DEFAULT NULL,
  `InfoCCC` char(1) DEFAULT 'F',
  `InfoNav` char(1) DEFAULT 'F',
  `InfoIV` char(1) DEFAULT 'F',
  `InfoFCA` char(1) DEFAULT 'F',
  `InfoBSU` char(1) DEFAULT 'F',
  `InfoCACM` char(1) DEFAULT 'F',
  `InfoEFCA` char(1) DEFAULT 'F',
  `InfoGCM` char(1) DEFAULT 'F',
  `InfoWesley` char(1) DEFAULT 'F',
  PRIMARY KEY (`ContactID`)
) ENGINE=InnoDB AUTO_INCREMENT=1124 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=529 DEFAULT CHARSET=latin1;

CREATE TABLE `mail_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` varchar(255) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `group_description` varchar(255) DEFAULT NULL,
  `email_permission` varchar(255) DEFAULT 'Domain',
  `email_query` text,
  `exists_on_google` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `update_interval` varchar(255) DEFAULT 'Daily',
  `contact_id` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `owners_email_query` text,
  PRIMARY KEY (`id`),
  KEY `index_mail_groups_on_group_id` (`group_id`),
  KEY `index_mail_groups_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=latin1;

CREATE TABLE `mail_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `exception` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mail_members_on_group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2069 DEFAULT CHARSET=latin1;

CREATE TABLE `mail_owners` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `exception` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=508 DEFAULT CHARSET=utf8;

CREATE TABLE `mail_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guid` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `employee_id` varchar(255) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `guid` (`guid`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;

CREATE TABLE `merge_audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mergeable_id` int(11) DEFAULT NULL,
  `mergeable_type` varchar(255) DEFAULT NULL,
  `merge_looser_id` int(11) DEFAULT NULL,
  `merge_looser_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mergeable` (`mergeable_id`,`mergeable_type`),
  KEY `merge_looser` (`merge_looser_id`,`merge_looser_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `mh_answer_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

CREATE TABLE `mh_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer_sheet_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `value` text,
  `short_value` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ma_answers_on_short_value` (`short_value`),
  KEY `index_ma_answers_on_answer_sheet_id` (`answer_sheet_id`),
  KEY `index_ma_answers_on_question_id` (`question_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `mh_conditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `trigger_id` int(11) NOT NULL,
  `expression` varchar(255) NOT NULL,
  `toggle_page_id` int(11) NOT NULL,
  `toggle_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mh_education_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) DEFAULT NULL,
  `school_type` varchar(255) DEFAULT NULL,
  `concentration_id1` varchar(255) DEFAULT NULL,
  `concentration_name1` varchar(255) DEFAULT NULL,
  `year_id` varchar(255) DEFAULT NULL,
  `year_name` varchar(255) DEFAULT NULL,
  `degree_id` varchar(255) DEFAULT NULL,
  `degree_name` varchar(255) DEFAULT NULL,
  `school_id` varchar(255) DEFAULT NULL,
  `school_name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `concentration_name2` varchar(255) DEFAULT NULL,
  `concentration_name3` varchar(255) DEFAULT NULL,
  `concentration_id2` varchar(255) DEFAULT NULL,
  `concentration_id3` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;

CREATE TABLE `mh_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kind` varchar(40) NOT NULL,
  `style` varchar(40) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `content` text,
  `required` tinyint(1) DEFAULT NULL,
  `slug` varchar(36) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `object_name` varchar(255) DEFAULT NULL,
  `attribute_name` varchar(255) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `value_xpath` varchar(255) DEFAULT NULL,
  `text_xpath` varchar(255) DEFAULT NULL,
  `question_grid_id` int(11) DEFAULT NULL,
  `cols` varchar(255) DEFAULT NULL,
  `is_confidential` tinyint(1) DEFAULT NULL,
  `total_cols` varchar(255) DEFAULT NULL,
  `css_id` varchar(255) DEFAULT NULL,
  `css_class` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `related_question_sheet_id` int(11) DEFAULT NULL,
  `conditional_id` int(11) DEFAULT NULL,
  `tooltip` text,
  `hide_label` tinyint(1) DEFAULT '0',
  `hide_option_labels` tinyint(1) DEFAULT '0',
  `max_length` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ma_elements_on_slug` (`slug`),
  KEY `index_ma_elements_on_question_sheet_id_and_position_and_page_id` (`position`),
  KEY `index_ma_elements_on_conditional_id` (`conditional_id`),
  KEY `index_ma_elements_on_question_grid_id` (`question_grid_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

CREATE TABLE `mh_email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(1000) NOT NULL,
  `content` text,
  `enabled` tinyint(1) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ma_email_templates_on_name` (`name`(767))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mh_friend` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=858 DEFAULT CHARSET=utf8;

CREATE TABLE `mh_interest` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `interest_id` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `interest_created_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8;

CREATE TABLE `mh_location` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;

CREATE TABLE `mh_page_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_id` int(11) DEFAULT NULL,
  `element_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

CREATE TABLE `mh_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `label` varchar(100) NOT NULL,
  `number` int(11) DEFAULT NULL,
  `no_cache` tinyint(1) DEFAULT '0',
  `hidden` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

CREATE TABLE `mh_question_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(60) NOT NULL,
  `archived` tinyint(1) DEFAULT '0',
  `questionnable_id` int(11) DEFAULT NULL,
  `questionnable_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `questionnable` (`questionnable_id`,`questionnable_type`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

CREATE TABLE `mh_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `applicant_answer_sheet_id` int(11) DEFAULT NULL,
  `email_sent_at` datetime DEFAULT NULL,
  `relationship` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `access_key` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ministries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_activity` (
  `ActivityID` int(10) NOT NULL AUTO_INCREMENT,
  `status` varchar(2) DEFAULT NULL,
  `periodBegin` datetime DEFAULT NULL,
  `periodEnd_deprecated` datetime DEFAULT NULL,
  `strategy` varchar(2) DEFAULT NULL,
  `transUsername` varchar(50) DEFAULT NULL,
  `fk_targetAreaID` int(10) DEFAULT NULL,
  `fk_teamID` int(10) DEFAULT NULL,
  `statusHistory_deprecated` varchar(2) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `sent_teamID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ActivityID`),
  KEY `index1` (`fk_targetAreaID`),
  KEY `index2` (`fk_teamID`),
  KEY `index3` (`periodBegin`),
  KEY `index5` (`strategy`)
) ENGINE=InnoDB AUTO_INCREMENT=12227 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_activity_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activity_id` int(11) NOT NULL,
  `from_status` varchar(2) DEFAULT NULL,
  `to_status` varchar(2) DEFAULT NULL,
  `period_begin` datetime DEFAULT NULL,
  `period_end` datetime DEFAULT NULL,
  `trans_username` varchar(50) DEFAULT NULL,
  `fromStrategy` varchar(255) DEFAULT NULL,
  `toStrategy` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `activity_id` (`activity_id`),
  KEY `period_begin` (`period_begin`),
  KEY `toStrategy` (`toStrategy`),
  KEY `to_status` (`to_status`)
) ENGINE=InnoDB AUTO_INCREMENT=20937 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_address` (
  `AddressID` int(10) NOT NULL AUTO_INCREMENT,
  `startdate` datetime DEFAULT NULL,
  `enddate` datetime DEFAULT NULL,
  `address1` varchar(60) DEFAULT NULL,
  `address2` varchar(60) DEFAULT NULL,
  `address3` varchar(60) DEFAULT NULL,
  `address4` varchar(60) DEFAULT NULL,
  `city` varchar(35) DEFAULT NULL,
  `state` varchar(6) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`AddressID`)
) ENGINE=InnoDB AUTO_INCREMENT=44616 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_assoc_activitycontact` (
  `ActivityID` int(10) NOT NULL,
  `accountNo` varchar(11) NOT NULL,
  `dbioDummy` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ActivityID`,`accountNo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_assoc_dependents` (
  `DependentID` int(10) NOT NULL,
  `accountNo` varchar(11) NOT NULL,
  `dbioDummy` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`DependentID`,`accountNo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_assoc_otherministries` (
  `NonCccMinID` varchar(64) NOT NULL,
  `TargetAreaID` varchar(64) NOT NULL,
  `dbioDummy` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`NonCccMinID`,`TargetAreaID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_authorization` (
  `AuthorizationID` int(10) NOT NULL AUTO_INCREMENT,
  `authdate` datetime DEFAULT NULL,
  `role` varchar(30) DEFAULT NULL,
  `authorized` varchar(1) DEFAULT NULL,
  `sequence` int(10) DEFAULT NULL,
  `fk_AuthorizedBy` varchar(11) DEFAULT NULL,
  `fk_AuthorizationNote` varchar(64) DEFAULT NULL,
  `fk_changeRequestID` int(10) DEFAULT NULL,
  PRIMARY KEY (`AuthorizationID`),
  KEY `index1` (`fk_AuthorizedBy`),
  KEY `index2` (`fk_changeRequestID`),
  KEY `index3` (`fk_AuthorizationNote`)
) ENGINE=InnoDB AUTO_INCREMENT=13894 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_changerequest` (
  `ChangeRequestID` int(10) NOT NULL AUTO_INCREMENT,
  `requestdate` datetime DEFAULT NULL,
  `effectivedate` datetime DEFAULT NULL,
  `applieddate` datetime DEFAULT NULL,
  `type` varchar(30) DEFAULT NULL,
  `fk_requestedBy` varchar(11) DEFAULT NULL,
  `updateStaff` varchar(11) DEFAULT NULL,
  `region` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`ChangeRequestID`),
  KEY `index1` (`fk_requestedBy`)
) ENGINE=InnoDB AUTO_INCREMENT=16005 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_dependent` (
  `DependentID` int(10) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(80) DEFAULT NULL,
  `middleName` varchar(80) DEFAULT NULL,
  `lastName` varchar(80) DEFAULT NULL,
  `birthdate` datetime DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`DependentID`)
) ENGINE=InnoDB AUTO_INCREMENT=4249 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_fieldchange` (
  `FieldChangeID` int(10) NOT NULL AUTO_INCREMENT,
  `field` varchar(30) DEFAULT NULL,
  `oldValue` varchar(255) DEFAULT NULL,
  `newValue` varchar(255) DEFAULT NULL,
  `Fk_hasFieldChanges` int(10) DEFAULT NULL,
  PRIMARY KEY (`FieldChangeID`)
) ENGINE=InnoDB AUTO_INCREMENT=54075 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_involvement` (
  `involvementID` int(11) NOT NULL AUTO_INCREMENT,
  `fk_PersonID` int(11) DEFAULT NULL,
  `fk_StrategyID` int(11) DEFAULT NULL,
  PRIMARY KEY (`involvementID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_locallevel` (
  `teamID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `lane` varchar(10) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `region` varchar(2) DEFAULT NULL,
  `address1` varchar(35) DEFAULT NULL,
  `address2` varchar(35) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `state` varchar(6) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `phone` varchar(24) DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `isActive` char(1) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `stopdate` datetime DEFAULT NULL,
  `Fk_OrgRel` varchar(64) DEFAULT NULL,
  `no` varchar(2) DEFAULT NULL,
  `abbrv` varchar(2) DEFAULT NULL,
  `hasMultiRegionalAccess` varchar(255) DEFAULT NULL,
  `dept_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`teamID`)
) ENGINE=InnoDB AUTO_INCREMENT=1132 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_missional_team_member` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `personID` int(11) DEFAULT NULL,
  `teamID` int(11) DEFAULT NULL,
  `is_people_soft` tinyint(1) DEFAULT NULL,
  `is_leader` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5024 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_movement_contact` (
  `personID` int(11) DEFAULT NULL,
  `ActivityID` int(11) DEFAULT NULL,
  KEY `personID` (`personID`),
  KEY `ActivityID` (`ActivityID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_newaddress` (
  `addressID` int(10) NOT NULL AUTO_INCREMENT,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `address3` varchar(55) DEFAULT NULL,
  `address4` varchar(55) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `zip` varchar(15) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `homePhone` varchar(26) DEFAULT NULL,
  `workPhone` varchar(250) DEFAULT NULL,
  `cellPhone` varchar(25) DEFAULT NULL,
  `fax` varchar(25) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `url` varchar(100) DEFAULT NULL,
  `contactName` varchar(50) DEFAULT NULL,
  `contactRelationship` varchar(50) DEFAULT NULL,
  `addressType` varchar(20) DEFAULT NULL,
  `dateCreated` datetime DEFAULT NULL,
  `dateChanged` datetime DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `changedBy` varchar(50) DEFAULT NULL,
  `fk_PersonID` int(10) DEFAULT NULL,
  `email2` varchar(200) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `facebook_link` varchar(255) DEFAULT NULL,
  `myspace_link` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `dorm` varchar(255) DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  `preferredPhone` varchar(25) DEFAULT NULL,
  `phone1_type` varchar(255) DEFAULT 'cell',
  `phone2_type` varchar(255) DEFAULT 'home',
  `phone3_type` varchar(255) DEFAULT 'work',
  PRIMARY KEY (`addressID`),
  UNIQUE KEY `unique_person_addressType` (`addressType`,`fk_PersonID`),
  KEY `fk_PersonID` (`fk_PersonID`),
  KEY `index_ministry_newAddress_on_addressType` (`addressType`),
  KEY `email` (`email`),
  CONSTRAINT `ministry_newaddress_ibfk_1` FOREIGN KEY (`fk_PersonID`) REFERENCES `ministry_person` (`personID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=693216 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_newaddress_restore` (
  `addressID` int(10) NOT NULL AUTO_INCREMENT,
  `deprecated_startDate` varchar(25) DEFAULT NULL,
  `deprecated_endDate` varchar(25) DEFAULT NULL,
  `address1` varchar(55) DEFAULT NULL,
  `address2` varchar(55) DEFAULT NULL,
  `address3` varchar(55) DEFAULT NULL,
  `address4` varchar(55) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `zip` varchar(15) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `homePhone` varchar(25) DEFAULT NULL,
  `workPhone` varchar(25) DEFAULT NULL,
  `cellPhone` varchar(25) DEFAULT NULL,
  `fax` varchar(25) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `url` varchar(100) DEFAULT NULL,
  `contactName` varchar(50) DEFAULT NULL,
  `contactRelationship` varchar(50) DEFAULT NULL,
  `addressType` varchar(255) DEFAULT NULL,
  `dateCreated` datetime DEFAULT NULL,
  `dateChanged` datetime DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `changedBy` varchar(50) DEFAULT NULL,
  `fk_PersonID` varchar(255) DEFAULT NULL,
  `email2` varchar(200) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `facebook_link` varchar(255) DEFAULT NULL,
  `myspace_link` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `dorm` varchar(255) DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`addressID`),
  UNIQUE KEY `unique_person_addressType` (`addressType`,`fk_PersonID`),
  KEY `fk_PersonID` (`fk_PersonID`),
  KEY `index_ministry_newaddress_restore_on_addressType` (`addressType`),
  KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=616413 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_noncccmin` (
  `NonCccMinID` int(10) NOT NULL AUTO_INCREMENT,
  `ministry` varchar(50) DEFAULT NULL,
  `firstName` varchar(30) DEFAULT NULL,
  `lastName` varchar(30) DEFAULT NULL,
  `address1` varchar(35) DEFAULT NULL,
  `address2` varchar(35) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `state` varchar(6) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `homePhone` varchar(24) DEFAULT NULL,
  `workPhone` varchar(24) DEFAULT NULL,
  `mobilePhone` varchar(24) DEFAULT NULL,
  `email` varchar(80) DEFAULT NULL,
  `url` varchar(50) DEFAULT NULL,
  `pager` varchar(24) DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`NonCccMinID`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_note` (
  `NoteID` int(10) NOT NULL AUTO_INCREMENT,
  `dateEntered` datetime DEFAULT NULL,
  `title` varchar(80) DEFAULT NULL,
  `note` text,
  `Fk_loaNote` varchar(64) DEFAULT NULL,
  `Fk_resignationLetter` varchar(64) DEFAULT NULL,
  `Fk_authorizationNote` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`NoteID`)
) ENGINE=InnoDB AUTO_INCREMENT=1150 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_person` (
  `personID` int(10) NOT NULL AUTO_INCREMENT,
  `accountNo` varchar(11) DEFAULT NULL,
  `lastName` varchar(50) DEFAULT NULL,
  `firstName` varchar(50) DEFAULT NULL,
  `middleName` varchar(50) DEFAULT NULL,
  `preferredName` varchar(50) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `region` varchar(5) DEFAULT NULL,
  `workInUS` tinyint(1) NOT NULL DEFAULT '1',
  `usCitizen` tinyint(1) NOT NULL DEFAULT '1',
  `citizenship` varchar(50) DEFAULT NULL,
  `isStaff` tinyint(1) DEFAULT NULL,
  `title` varchar(5) DEFAULT NULL,
  `campus` varchar(128) DEFAULT NULL,
  `universityState` varchar(5) DEFAULT NULL,
  `yearInSchool` varchar(20) DEFAULT NULL,
  `major` varchar(70) DEFAULT NULL,
  `minor` varchar(70) DEFAULT NULL,
  `greekAffiliation` varchar(50) DEFAULT NULL,
  `maritalStatus` varchar(20) DEFAULT NULL,
  `numberChildren` varchar(2) DEFAULT NULL,
  `isChild` tinyint(1) NOT NULL DEFAULT '0',
  `bio` longtext,
  `image` varchar(100) DEFAULT NULL,
  `occupation` varchar(50) DEFAULT NULL,
  `blogfeed` varchar(200) DEFAULT NULL,
  `cruCommonsInvite` datetime DEFAULT NULL,
  `cruCommonsLastLogin` datetime DEFAULT NULL,
  `dateCreated` datetime DEFAULT NULL,
  `dateChanged` datetime DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `changedBy` varchar(50) DEFAULT NULL,
  `fk_ssmUserId` int(10) DEFAULT NULL,
  `fk_StaffSiteProfileID` int(10) DEFAULT NULL,
  `fk_spouseID` int(10) DEFAULT NULL,
  `fk_childOf` int(10) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `date_became_christian` date DEFAULT NULL,
  `graduation_date` date DEFAULT NULL,
  `level_of_school` varchar(255) DEFAULT NULL,
  `staff_notes` varchar(255) DEFAULT NULL,
  `donor_number` varchar(11) DEFAULT NULL,
  `url` varchar(2000) DEFAULT NULL,
  `isSecure` char(1) DEFAULT NULL,
  `primary_campus_involvement_id` int(11) DEFAULT NULL,
  `mentor_id` int(11) DEFAULT NULL,
  `lastAttended` varchar(20) DEFAULT NULL,
  `ministry` varchar(255) DEFAULT NULL,
  `strategy` varchar(20) DEFAULT NULL,
  `fb_uid` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`personID`),
  KEY `accountNo_ministry_Person` (`accountNo`),
  KEY `firstname_ministry_Person` (`firstName`),
  KEY `lastname_ministry_Person` (`lastName`),
  KEY `region_ministry_Person` (`region`),
  KEY `fk_ssmUserId` (`fk_ssmUserId`),
  KEY `campus` (`campus`),
  KEY `index_ministry_person_on_fb_uid` (`fb_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=1723625 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_regionalstat` (
  `RegionalStatID` int(10) NOT NULL AUTO_INCREMENT,
  `periodBegin` datetime DEFAULT NULL,
  `periodEnd` datetime DEFAULT NULL,
  `nsSc` int(10) DEFAULT NULL,
  `nsWsn` int(10) DEFAULT NULL,
  `nsCat` int(10) DEFAULT NULL,
  `nsIcrD` int(10) DEFAULT NULL,
  `nsIcrI` int(10) DEFAULT NULL,
  `nsIcrE` int(10) DEFAULT NULL,
  `niSc` int(10) DEFAULT NULL,
  `niWsn` int(10) DEFAULT NULL,
  `niCat` int(10) DEFAULT NULL,
  `niIcrD` int(10) DEFAULT NULL,
  `niIcrI` int(10) DEFAULT NULL,
  `niIcrE` int(10) DEFAULT NULL,
  `fk_regionalTeamID` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`RegionalStatID`),
  KEY `fk_regionalTeamID` (`fk_regionalTeamID`)
) ENGINE=InnoDB AUTO_INCREMENT=319 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_regionalteam` (
  `teamID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `region` varchar(2) DEFAULT NULL,
  `address1` varchar(35) DEFAULT NULL,
  `address2` varchar(35) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `state` varchar(6) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `phone` varchar(24) DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `isActive` char(1) DEFAULT NULL,
  `startdate` datetime DEFAULT NULL,
  `stopdate` datetime DEFAULT NULL,
  `no` varchar(80) DEFAULT NULL,
  `abbrv` varchar(80) DEFAULT NULL,
  `hrd` varchar(50) DEFAULT NULL,
  `spPhone` varchar(24) DEFAULT NULL,
  PRIMARY KEY (`teamID`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_staff` (
  `accountNo` varchar(11) NOT NULL,
  `firstName` varchar(30) DEFAULT NULL,
  `middleInitial` varchar(1) DEFAULT NULL,
  `lastName` varchar(30) DEFAULT NULL,
  `isMale` char(1) DEFAULT NULL,
  `position` varchar(30) DEFAULT NULL,
  `countryStatus` varchar(10) DEFAULT NULL,
  `jobStatus` varchar(60) DEFAULT NULL,
  `ministry` varchar(35) DEFAULT NULL,
  `strategy` varchar(20) DEFAULT NULL,
  `isNewStaff` char(1) DEFAULT NULL,
  `primaryEmpLocState` varchar(6) DEFAULT NULL,
  `primaryEmpLocCountry` varchar(64) DEFAULT NULL,
  `primaryEmpLocCity` varchar(35) DEFAULT NULL,
  `primaryEmpLocDesc` varchar(128) DEFAULT NULL,
  `spouseFirstName` varchar(22) DEFAULT NULL,
  `spouseMiddleName` varchar(15) DEFAULT NULL,
  `spouseLastName` varchar(30) DEFAULT NULL,
  `spouseAccountNo` varchar(11) DEFAULT NULL,
  `spouseEmail` varchar(50) DEFAULT NULL,
  `fianceeFirstName` varchar(15) DEFAULT NULL,
  `fianceeMiddleName` varchar(15) DEFAULT NULL,
  `fianceeLastName` varchar(30) DEFAULT NULL,
  `fianceeAccountno` varchar(11) DEFAULT NULL,
  `isFianceeStaff` char(1) DEFAULT NULL,
  `fianceeJoinStaffDate` datetime DEFAULT NULL,
  `isFianceeJoiningNS` char(1) DEFAULT NULL,
  `joiningNS` char(1) DEFAULT NULL,
  `homePhone` varchar(24) DEFAULT NULL,
  `workPhone` varchar(24) DEFAULT NULL,
  `mobilePhone` varchar(24) DEFAULT NULL,
  `pager` varchar(24) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `isEmailSecure` char(1) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `newStaffTrainingdate` datetime DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  `note` varchar(2048) DEFAULT NULL,
  `region` varchar(10) DEFAULT NULL,
  `countryCode` varchar(3) DEFAULT NULL,
  `ssn` varchar(9) DEFAULT NULL,
  `maritalStatus` varchar(1) DEFAULT NULL,
  `deptId` varchar(10) DEFAULT NULL,
  `jobCode` varchar(6) DEFAULT NULL,
  `accountCode` varchar(25) DEFAULT NULL,
  `compFreq` varchar(1) DEFAULT NULL,
  `compRate` varchar(20) DEFAULT NULL,
  `compChngAmt` varchar(21) DEFAULT NULL,
  `jobTitle` varchar(80) DEFAULT NULL,
  `deptName` varchar(30) DEFAULT NULL,
  `coupleTitle` varchar(12) DEFAULT NULL,
  `otherPhone` varchar(24) DEFAULT NULL,
  `preferredName` varchar(50) DEFAULT NULL,
  `namePrefix` varchar(4) DEFAULT NULL,
  `origHiredate` datetime DEFAULT NULL,
  `birthDate` datetime DEFAULT NULL,
  `marriageDate` datetime DEFAULT NULL,
  `hireDate` datetime DEFAULT NULL,
  `rehireDate` datetime DEFAULT NULL,
  `loaStartDate` datetime DEFAULT NULL,
  `loaEndDate` datetime DEFAULT NULL,
  `loaReason` varchar(80) DEFAULT NULL,
  `severancePayMonthsReq` int(10) DEFAULT NULL,
  `serviceDate` datetime DEFAULT NULL,
  `lastIncDate` datetime DEFAULT NULL,
  `jobEntryDate` datetime DEFAULT NULL,
  `deptEntryDate` datetime DEFAULT NULL,
  `reportingDate` datetime DEFAULT NULL,
  `employmentType` varchar(20) DEFAULT NULL,
  `resignationReason` varchar(80) DEFAULT NULL,
  `resignationDate` datetime DEFAULT NULL,
  `contributionsToOtherAcct` char(1) DEFAULT NULL,
  `contributionsToAcntName` varchar(80) DEFAULT NULL,
  `contributionsToAcntNo` varchar(11) DEFAULT NULL,
  `fk_primaryAddress` int(10) DEFAULT NULL,
  `fk_secondaryAddress` int(10) DEFAULT NULL,
  `fk_teamID` int(10) DEFAULT NULL,
  `isSecure` char(1) DEFAULT NULL,
  `isSupported` char(1) DEFAULT NULL,
  `removedFromPeopleSoft` char(1) DEFAULT 'N',
  `isNonUSStaff` char(1) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `middleName` varchar(30) DEFAULT NULL,
  `paygroup` varchar(3) DEFAULT NULL,
  `idType` varchar(2) DEFAULT NULL,
  `statusDescr` varchar(30) DEFAULT NULL,
  `internationalStatus` varchar(3) DEFAULT NULL,
  `balance` decimal(9,2) DEFAULT NULL,
  `cccHrSendingDept` varchar(10) DEFAULT NULL,
  `cccHrCaringDept` varchar(10) DEFAULT NULL,
  `cccCaringMinistry` varchar(10) DEFAULT NULL,
  `assignmentLength` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accountNo` (`accountNo`),
  KEY `index1` (`fk_teamID`),
  KEY `index2` (`fk_primaryAddress`),
  KEY `index3` (`fk_secondaryAddress`),
  KEY `index4` (`lastName`),
  KEY `index5` (`region`),
  KEY `ministry_staff_person_id_index` (`person_id`),
  KEY `index_ministry_staff_on_firstName` (`firstName`)
) ENGINE=InnoDB AUTO_INCREMENT=20563 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_staffchangerequest` (
  `ChangeRequestID` varchar(64) NOT NULL,
  `updateStaff` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`ChangeRequestID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_statistic` (
  `StatisticID` int(10) NOT NULL AUTO_INCREMENT,
  `periodBegin` datetime DEFAULT NULL,
  `periodEnd` datetime DEFAULT NULL,
  `exposures` int(10) DEFAULT NULL,
  `exposuresViaMedia` int(10) DEFAULT NULL,
  `evangelisticOneOnOne` int(10) DEFAULT NULL,
  `evangelisticGroup` int(10) DEFAULT NULL,
  `decisions` int(10) DEFAULT NULL,
  `attendedLastConf` int(10) DEFAULT NULL,
  `invldNewBlvrs` int(10) DEFAULT NULL,
  `invldStudents` int(10) DEFAULT NULL,
  `invldFreshmen` int(10) DEFAULT NULL,
  `invldSophomores` int(10) DEFAULT NULL,
  `invldJuniors` int(10) DEFAULT NULL,
  `invldSeniors` int(10) DEFAULT NULL,
  `invldGrads` int(10) DEFAULT NULL,
  `studentLeaders` int(10) DEFAULT NULL,
  `volunteers` int(10) DEFAULT NULL,
  `staff` int(10) DEFAULT NULL,
  `nonStaffStint` int(10) DEFAULT NULL,
  `staffStint` int(10) DEFAULT NULL,
  `fk_Activity` int(10) DEFAULT NULL,
  `multipliers` int(11) DEFAULT NULL,
  `laborersSent` int(11) DEFAULT NULL,
  `decisionsHelpedByMedia` int(11) DEFAULT NULL,
  `decisionsHelpedByOneOnOne` int(11) DEFAULT NULL,
  `decisionsHelpedByGroup` int(11) DEFAULT NULL,
  `decisionsHelpedByOngoingReln` int(11) DEFAULT NULL,
  `ongoingEvangReln` int(11) DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `peopleGroup` varchar(255) DEFAULT NULL,
  `holySpiritConversations` int(11) DEFAULT NULL,
  `dollars_raised` int(11) DEFAULT NULL,
  PRIMARY KEY (`StatisticID`),
  UNIQUE KEY `activityWeekPeopleGroup` (`periodEnd`,`fk_Activity`,`peopleGroup`),
  KEY `index1` (`fk_Activity`),
  KEY `index2` (`periodBegin`),
  KEY `index3` (`periodEnd`)
) ENGINE=InnoDB AUTO_INCREMENT=74079 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_strategy` (
  `strategyID` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `abreviation` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`strategyID`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `ministry_targetarea` (
  `targetAreaID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `address1` varchar(35) DEFAULT NULL,
  `address2` varchar(35) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `state` varchar(32) DEFAULT NULL,
  `zip` varchar(10) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `phone` varchar(24) DEFAULT NULL,
  `fax` varchar(24) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `abbrv` varchar(32) DEFAULT NULL,
  `fice` varchar(32) DEFAULT NULL,
  `mainCampusFice` varchar(32) DEFAULT NULL,
  `isNoFiceOK` char(1) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `altName` varchar(100) DEFAULT NULL,
  `isSecure` char(1) DEFAULT NULL,
  `isClosed` char(1) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `mpta` varchar(30) DEFAULT NULL,
  `urlToLogo` varchar(255) DEFAULT NULL,
  `enrollment` varchar(10) DEFAULT NULL,
  `monthSchoolStarts` varchar(10) DEFAULT NULL,
  `monthSchoolStops` varchar(10) DEFAULT NULL,
  `isSemester` char(1) DEFAULT NULL,
  `isApproved` char(1) DEFAULT NULL,
  `aoaPriority` varchar(10) DEFAULT NULL,
  `aoa` varchar(100) DEFAULT NULL,
  `ciaUrl` varchar(255) DEFAULT NULL,
  `infoUrl` varchar(255) DEFAULT NULL,
  `calendar` varchar(50) DEFAULT NULL,
  `program1` varchar(50) DEFAULT NULL,
  `program2` varchar(50) DEFAULT NULL,
  `program3` varchar(50) DEFAULT NULL,
  `program4` varchar(50) DEFAULT NULL,
  `program5` varchar(50) DEFAULT NULL,
  `emphasis` varchar(50) DEFAULT NULL,
  `sex` varchar(50) DEFAULT NULL,
  `institutionType` varchar(50) DEFAULT NULL,
  `highestOffering` varchar(65) DEFAULT NULL,
  `affiliation` varchar(50) DEFAULT NULL,
  `carnegieClassification` varchar(100) DEFAULT NULL,
  `irsStatus` varchar(50) DEFAULT NULL,
  `establishedDate` int(10) DEFAULT NULL,
  `tuition` int(10) DEFAULT NULL,
  `modified` datetime DEFAULT NULL,
  `eventType` varchar(2) DEFAULT NULL,
  `eventKeyID` int(10) DEFAULT NULL,
  `type` varchar(20) DEFAULT NULL,
  `county` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`targetAreaID`),
  KEY `index1` (`name`),
  KEY `index2` (`isApproved`),
  KEY `index3` (`state`),
  KEY `index4` (`country`),
  KEY `index5` (`isSecure`),
  KEY `index6` (`region`),
  KEY `index7` (`isClosed`)
) ENGINE=InnoDB AUTO_INCREMENT=22348 DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_contact_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mpd_contact_id` int(11) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `gift_amount` float DEFAULT NULL,
  `letter_sent` tinyint(1) DEFAULT '0',
  `contacted` tinyint(1) DEFAULT '0',
  `thankyou_sent` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_selected_letter` tinyint(1) DEFAULT NULL,
  `is_selected_call` tinyint(1) DEFAULT NULL,
  `is_selected_thankyou` tinyint(1) DEFAULT NULL,
  `postproject_sent` tinyint(1) DEFAULT '0',
  `partner_financial` tinyint(1) DEFAULT '0',
  `partner_prayer` tinyint(1) DEFAULT '0',
  `gift_pledged` tinyint(1) DEFAULT '0',
  `gift_received` tinyint(1) DEFAULT '0',
  `date_received` varchar(255) DEFAULT NULL,
  `form_received` varchar(255) DEFAULT 'Not Received',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mpd_contact_actions_on_mpd_contact_id_and_event_id` (`mpd_contact_id`,`event_id`),
  KEY `mpd_contact_id` (`mpd_contact_id`),
  KEY `event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mpd_user_id` int(11) DEFAULT NULL,
  `mpd_priority_id` int(11) DEFAULT NULL,
  `full_name` varchar(255) NOT NULL DEFAULT '',
  `address_1` varchar(255) DEFAULT '',
  `address_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT '',
  `state` varchar(255) DEFAULT '',
  `zip` varchar(10) DEFAULT '',
  `phone` varchar(15) DEFAULT '',
  `email_address` varchar(255) DEFAULT '',
  `notes` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `salutation` varchar(255) DEFAULT NULL,
  `phone_2` varchar(25) DEFAULT '',
  `relationship` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `mpd_contacts_mpd_user_id_index` (`mpd_user_id`),
  KEY `mpd_contacts_mpd_priority_id_index` (`mpd_priority_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `cost` int(11) DEFAULT NULL,
  `mpd_user_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `current_letter` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mpd_user_id` (`mpd_user_id`),
  KEY `project_id` (`project_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_expense_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `default_amount` float DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_expenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mpd_user_id` int(11) DEFAULT NULL,
  `mpd_expense_type_id` int(11) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT '0',
  `mpd_event_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mpd_expenses_mpd_user_id_index` (`mpd_user_id`),
  KEY `mpd_expenses_mpd_expense_type_id_index` (`mpd_expense_type_id`),
  KEY `mpd_event_id` (`mpd_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_letter_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mpd_letter_id` int(11) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `photo_file_name` varchar(255) DEFAULT NULL,
  `photo_content_type` varchar(255) DEFAULT NULL,
  `photo_file_size` int(11) DEFAULT NULL,
  `photo_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mpd_letter_id` (`mpd_letter_id`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_letter_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `thumbnail_filename` varchar(255) DEFAULT '',
  `pdf_preview_filename` varchar(255) DEFAULT '',
  `description` text,
  `number_of_images` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_letters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mpd_letter_template_id` int(11) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `salutation` varchar(255) DEFAULT 'Dear [[SALUTATION]],',
  `update_section` text,
  `educate_section` text,
  `needs_section` text,
  `involve_section` text,
  `acknowledge_section` text,
  `closing` varchar(255) DEFAULT 'Thank you,',
  `printed_name` varchar(255) DEFAULT NULL,
  `mpd_user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mpd_letters_mpd_letter_template_id_index` (`mpd_letter_template_id`),
  KEY `mpd_letters_mpd_user_id_index` (`mpd_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_priorities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mpd_user_id` int(11) NOT NULL DEFAULT '0',
  `rateable_id` int(11) NOT NULL DEFAULT '0',
  `priority` int(11) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `rateable_type` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `fk_mpd_priorities_mpd_user` (`mpd_user_id`),
  KEY `rateable_id` (`rateable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_roles_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `role_id` (`role_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mpd_sessions_on_session_id` (`session_id`),
  KEY `index_mpd_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mpd_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `mpd_role_id` int(11) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `show_welcome` tinyint(1) DEFAULT '1',
  `show_follow_up_help` tinyint(1) DEFAULT '1',
  `show_calculator` tinyint(1) DEFAULT '1',
  `show_thank_help` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `current_event_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mpd_users_mpd_role_id_index` (`mpd_role_id`),
  KEY `mpd_users_ssm_id_index` (`user_id`),
  KEY `current_event_id` (`current_event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `nag_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ssm_id` int(11) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(10) DEFAULT '0',
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `nags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `query` text,
  `email` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` text,
  `emailfield` varchar(255) DEFAULT NULL,
  `userbody` text,
  `usersubject` text,
  `period` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

CREATE TABLE `old_wsn_sp_wsnapplication` (
  `WsnApplicationID` int(10) NOT NULL AUTO_INCREMENT,
  `oldPrimaryKey` varchar(64) DEFAULT NULL,
  `surferID` varchar(64) DEFAULT NULL,
  `role` varchar(1) DEFAULT NULL,
  `region` varchar(2) DEFAULT NULL,
  `legalLastName` varchar(50) DEFAULT NULL,
  `legalFirstName` varchar(50) DEFAULT NULL,
  `ssn` varchar(11) DEFAULT NULL,
  `currentAddress` varchar(50) DEFAULT NULL,
  `currentAddress2` varchar(35) DEFAULT NULL,
  `currentCity` varchar(35) DEFAULT NULL,
  `currentState` varchar(6) DEFAULT NULL,
  `currentZip` varchar(10) DEFAULT NULL,
  `currentPhone` varchar(24) DEFAULT NULL,
  `currentEmail` varchar(50) DEFAULT NULL,
  `dateAddressGoodUntil` varchar(22) DEFAULT NULL,
  `birthdate` varchar(22) DEFAULT NULL,
  `dateBecameChristian` varchar(30) DEFAULT NULL,
  `maritalStatus` varchar(22) DEFAULT NULL,
  `universityFullName` varchar(100) DEFAULT NULL,
  `major` varchar(50) DEFAULT NULL,
  `yearInSchool` varchar(12) DEFAULT NULL,
  `graduationDate` varchar(22) DEFAULT NULL,
  `earliestAvailableDate` varchar(22) DEFAULT NULL,
  `dateMustReturn` varchar(22) DEFAULT NULL,
  `willingForDifferentProject` tinyint(1) DEFAULT '1',
  `usCitizen` tinyint(1) DEFAULT '1',
  `citizenship` varchar(50) DEFAULT NULL,
  `isApplicationComplete` tinyint(1) DEFAULT '0',
  `applicationCompleteNote` tinyint(1) DEFAULT '0',
  `projectPref1` varchar(64) DEFAULT NULL,
  `projectPref2` varchar(64) DEFAULT NULL,
  `projectPref3` varchar(64) DEFAULT NULL,
  `projectPref4` varchar(64) DEFAULT NULL,
  `projectPref5` varchar(64) DEFAULT NULL,
  `applAccountNo` varchar(11) DEFAULT NULL,
  `supportGoal` int(10) DEFAULT NULL,
  `supportReceived` int(10) DEFAULT NULL,
  `supportBalance` float DEFAULT NULL,
  `insuranceReceived` tinyint(1) DEFAULT '0',
  `waiverReceived` tinyint(1) DEFAULT '0',
  `didGo` tinyint(1) DEFAULT '0',
  `participantEvaluation` tinyint(1) DEFAULT '0',
  `destinationGatewayCity` varchar(50) DEFAULT NULL,
  `gatewayCityToLocationFlightNo` varchar(50) DEFAULT NULL,
  `departGatewayCityToLocation` varchar(22) DEFAULT NULL,
  `arrivalGatewayCityToLocation` varchar(22) DEFAULT NULL,
  `locationToGatewayCityFlightNo` varchar(50) DEFAULT NULL,
  `departLocationToGatewayCity` varchar(22) DEFAULT NULL,
  `arrrivalLocationToGatewayCity` varchar(22) DEFAULT NULL,
  `domesticOrigin` varchar(50) DEFAULT NULL,
  `domesticOriginToGCFlightNo` varchar(50) DEFAULT NULL,
  `departDomesticToGatewayCity` varchar(22) DEFAULT NULL,
  `arrivalDomesticToGatewayCity` varchar(22) DEFAULT NULL,
  `arrivalAtDomesticOrigin` varchar(22) DEFAULT NULL,
  `travelPlans` tinyint(1) DEFAULT '0',
  `travelDeviation` tinyint(1) DEFAULT '0',
  `passportNo` varchar(25) DEFAULT NULL,
  `passportCountry` varchar(50) DEFAULT NULL,
  `passportIssueDate` varchar(22) DEFAULT NULL,
  `passportExpirationDate` varchar(22) DEFAULT NULL,
  `visaCountry` varchar(50) DEFAULT NULL,
  `visaNo` varchar(50) DEFAULT NULL,
  `visaType` varchar(50) DEFAULT NULL,
  `visaIsMultipleEntry` tinyint(1) DEFAULT '0',
  `visaIssueDate` varchar(22) DEFAULT NULL,
  `visaExpirationDate` varchar(22) DEFAULT NULL,
  `emergName` varchar(50) DEFAULT NULL,
  `emergAddress` varchar(50) DEFAULT NULL,
  `emergCity` varchar(50) DEFAULT NULL,
  `emergState` varchar(6) DEFAULT NULL,
  `emergZip` varchar(10) DEFAULT NULL,
  `emergPhone` varchar(24) DEFAULT NULL,
  `emergWorkPhone` varchar(24) DEFAULT NULL,
  `emergEmail` varchar(50) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `dateUpdated` varchar(22) DEFAULT NULL,
  `isStaff` tinyint(1) DEFAULT '0',
  `prevIsp` tinyint(1) DEFAULT '0',
  `child` tinyint(1) DEFAULT '0',
  `status` varchar(22) DEFAULT NULL,
  `wsnYear` varchar(4) DEFAULT NULL,
  `fk_isMember` varchar(64) DEFAULT NULL,
  `fk_wsnSpouse` varchar(64) DEFAULT NULL,
  `fk_childOf` varchar(64) DEFAULT NULL,
  `fk_infobaseID` varchar(64) DEFAULT NULL,
  `fk_ssmUserID` int(10) DEFAULT NULL,
  `inSchool` tinyint(1) DEFAULT '1',
  `weight` int(10) DEFAULT NULL,
  `heightFeet` int(10) DEFAULT NULL,
  `heightInches` int(10) DEFAULT NULL,
  `participateImpact` tinyint(1) DEFAULT '0',
  `participateDestino` tinyint(1) DEFAULT '0',
  `participateEpic` tinyint(1) DEFAULT NULL,
  `springBreakStart` datetime DEFAULT NULL,
  `springBreakEnd` datetime DEFAULT NULL,
  `isIntern` tinyint(1) DEFAULT '0',
  `_1a` tinyint(1) DEFAULT '0',
  `_1b` tinyint(1) DEFAULT '0',
  `_1c` tinyint(1) DEFAULT '0',
  `_1d` tinyint(1) DEFAULT '0',
  `_1e` tinyint(1) DEFAULT '0',
  `_1f` longtext,
  `_2a` tinyint(1) DEFAULT NULL,
  `_2b` longtext,
  `_2c` tinyint(1) DEFAULT NULL,
  `_3a` tinyint(1) DEFAULT NULL,
  `_3b` tinyint(1) DEFAULT NULL,
  `_3c` tinyint(1) DEFAULT NULL,
  `_3d` tinyint(1) DEFAULT NULL,
  `_3e` tinyint(1) DEFAULT NULL,
  `_3f` tinyint(1) DEFAULT NULL,
  `_3g` tinyint(1) DEFAULT NULL,
  `_3h` longtext,
  `_4a` tinyint(1) DEFAULT NULL,
  `_4b` tinyint(1) DEFAULT NULL,
  `_4c` tinyint(1) DEFAULT NULL,
  `_4d` tinyint(1) DEFAULT NULL,
  `_4e` tinyint(1) DEFAULT NULL,
  `_4f` tinyint(1) DEFAULT NULL,
  `_4g` tinyint(1) DEFAULT NULL,
  `_4h` tinyint(1) DEFAULT NULL,
  `_4i` longtext,
  `_5a` tinyint(1) DEFAULT NULL,
  `_5b` tinyint(1) DEFAULT NULL,
  `_5c` tinyint(1) DEFAULT NULL,
  `_5d` tinyint(1) DEFAULT NULL,
  `_5e` longtext,
  `_5f` tinyint(1) DEFAULT NULL,
  `_5g` longtext,
  `_5h` tinyint(1) DEFAULT NULL,
  `_6` longtext,
  `_7` longtext,
  `_8a` longtext,
  `_8b` longtext,
  `_9` longtext,
  `_10` longtext,
  `_11a` tinyint(1) DEFAULT NULL,
  `_11b` longtext,
  `_12a` tinyint(1) DEFAULT NULL,
  `_12b` longtext,
  `_13a` tinyint(1) DEFAULT NULL,
  `_13b` tinyint(1) DEFAULT NULL,
  `_13c` tinyint(1) DEFAULT NULL,
  `_14` longtext,
  `_15` tinyint(1) DEFAULT NULL,
  `_16` int(10) DEFAULT NULL,
  `_17` int(10) DEFAULT NULL,
  `_18` int(10) DEFAULT NULL,
  `_19a` tinyint(1) DEFAULT NULL,
  `_19b` tinyint(1) DEFAULT NULL,
  `_19c` tinyint(1) DEFAULT NULL,
  `_19d` tinyint(1) DEFAULT NULL,
  `_19e` tinyint(1) DEFAULT NULL,
  `_19f` varchar(255) DEFAULT NULL,
  `_20a` longtext,
  `_20b` longtext,
  `_20c` longtext,
  `_21a` tinyint(1) DEFAULT NULL,
  `_21b` tinyint(1) DEFAULT NULL,
  `_21c` tinyint(1) DEFAULT NULL,
  `_21d` tinyint(1) DEFAULT NULL,
  `_21e` tinyint(1) DEFAULT NULL,
  `_21f` tinyint(1) DEFAULT NULL,
  `_21g` tinyint(1) DEFAULT NULL,
  `_21h` tinyint(1) DEFAULT NULL,
  `_21i` longtext,
  `_21j` char(1) DEFAULT NULL,
  `_22a` tinyint(1) DEFAULT NULL,
  `_22b` longtext,
  `_23a` tinyint(1) DEFAULT NULL,
  `_23b` longtext,
  `_24a` tinyint(1) DEFAULT NULL,
  `_24b` longtext,
  `_25` longtext,
  `_26a` tinyint(1) DEFAULT NULL,
  `_26b` longtext,
  `_27a` tinyint(1) DEFAULT NULL,
  `_27b` longtext,
  `_28a` tinyint(1) DEFAULT NULL,
  `_28b` longtext,
  `_29a` tinyint(1) DEFAULT NULL,
  `_29b` longtext,
  `_29c` tinyint(1) DEFAULT NULL,
  `_29d` tinyint(1) DEFAULT NULL,
  `_29e` longtext,
  `_29f` longtext,
  `_30` longtext,
  `_31` longtext,
  `_32` longtext,
  `_33` longtext,
  `_34` longtext,
  `_35` longtext,
  `isPaid` tinyint(1) DEFAULT NULL,
  `applicationStatus` varchar(50) DEFAULT NULL,
  `isApplyingForStaffInternship` tinyint(1) DEFAULT NULL,
  `createDate` datetime DEFAULT NULL,
  `lastChangedDate` datetime DEFAULT NULL,
  `lastChangedBy` varchar(30) DEFAULT NULL,
  `currentCellPhone` varchar(24) DEFAULT NULL,
  `emergAddress2` varchar(35) DEFAULT NULL,
  `legalMiddleName` varchar(50) DEFAULT NULL,
  `title` varchar(10) DEFAULT NULL,
  `isRecruited` tinyint(1) DEFAULT NULL,
  `assignedToProject` varchar(64) DEFAULT NULL,
  `datePaymentRecieved` datetime DEFAULT NULL,
  `evaluationStatus` varchar(50) DEFAULT NULL,
  `universityState` varchar(2) DEFAULT NULL,
  `finalProject` varchar(64) DEFAULT NULL,
  `electronicSignature` varchar(50) DEFAULT NULL,
  `submittedDate` datetime DEFAULT NULL,
  `assignedDate` datetime DEFAULT NULL,
  `dateReferencesDone` datetime DEFAULT NULL,
  `acceptedDate` datetime DEFAULT NULL,
  `notAcceptedDate` datetime DEFAULT NULL,
  `withdrawnDate` datetime DEFAULT NULL,
  `finalWsnProjectID` varchar(64) DEFAULT NULL,
  `preferredContactMethod` varchar(1) DEFAULT NULL,
  `howOftenCheckEmail` varchar(30) DEFAULT NULL,
  `otherClassDetails` varchar(30) DEFAULT NULL,
  `participateOtherProjects` tinyint(1) DEFAULT NULL,
  `campusHasStaffTeam` tinyint(1) DEFAULT NULL,
  `campusHasStaffCoach` tinyint(1) DEFAULT NULL,
  `campusHasMetroTeam` tinyint(1) DEFAULT NULL,
  `campusHasOther` tinyint(1) DEFAULT NULL,
  `campusHasOtherDetails` varchar(30) DEFAULT NULL,
  `inSchoolNextFall` tinyint(1) DEFAULT NULL,
  `participateCCC` tinyint(1) DEFAULT NULL,
  `participateNone` tinyint(1) DEFAULT NULL,
  `ciPhoneCallRequested` tinyint(1) DEFAULT NULL,
  `ciPhoneNumber` varchar(24) DEFAULT NULL,
  `ciBestTimeToCall` varchar(10) DEFAULT NULL,
  `ciTimeZone` varchar(10) DEFAULT NULL,
  `_26date` varchar(10) DEFAULT NULL,
  `appType` varchar(64) DEFAULT NULL,
  `fk_personID` int(10) DEFAULT NULL,
  PRIMARY KEY (`WsnApplicationID`),
  KEY `index1` (`fk_isMember`),
  KEY `index10` (`applAccountNo`),
  KEY `index11` (`region`),
  KEY `index2` (`fk_wsnSpouse`),
  KEY `index3` (`fk_childOf`),
  KEY `index8` (`status`),
  KEY `index9` (`wsnYear`),
  KEY `fk_personID` (`fk_personID`)
) ENGINE=MyISAM AUTO_INCREMENT=32617 DEFAULT CHARSET=utf8;

CREATE TABLE `oncampus_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `purpose` varchar(100) NOT NULL,
  `payment` varchar(100) NOT NULL,
  `format_dvd` tinyint(1) NOT NULL DEFAULT '1',
  `format_quicktime` tinyint(1) NOT NULL DEFAULT '0',
  `format_flash` tinyint(1) NOT NULL DEFAULT '0',
  `campus` varchar(100) NOT NULL,
  `campus_state` varchar(50) NOT NULL,
  `commercial_movement_name` varchar(200) NOT NULL,
  `commercial_school_name` varchar(200) DEFAULT NULL,
  `commercial_additional_info` text,
  `user_agreement` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(20) NOT NULL DEFAULT 'submitted',
  `created_at` datetime NOT NULL,
  `commercial_website` varchar(300) DEFAULT NULL,
  `commercial_logo` tinyint(1) DEFAULT '1',
  `color` varchar(20) DEFAULT '#FFFFFF',
  `produced_at` datetime DEFAULT NULL,
  `shipped_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

CREATE TABLE `oncampus_uses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `type` varchar(20) NOT NULL,
  `context` varchar(20) NOT NULL,
  `title` varchar(150) NOT NULL,
  `date_start` datetime DEFAULT NULL,
  `date_end` datetime DEFAULT NULL,
  `single_event` tinyint(1) NOT NULL DEFAULT '0',
  `commercial_frisbee` tinyint(1) NOT NULL DEFAULT '0',
  `commercial_ramen` tinyint(1) NOT NULL DEFAULT '0',
  `description` text NOT NULL,
  `feedback` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

CREATE TABLE `organization_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT '0',
  `validated` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `followup_status` enum('uncontacted','attempted_contact','contacted','do_not_contact','completed') DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organization_memberships_on_organization_id_and_person_id` (`organization_id`,`person_id`),
  KEY `index_organization_memberships_on_followup_status` (`followup_status`)
) ENGINE=InnoDB AUTO_INCREMENT=101595 DEFAULT CHARSET=latin1;

CREATE TABLE `organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `requires_validation` tinyint(1) DEFAULT '0',
  `validation_method` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `terminology` varchar(255) DEFAULT NULL,
  `importable_id` int(11) DEFAULT NULL,
  `importable_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organizations_on_importable_type_and_importable_id` (`importable_type`,`importable_id`),
  KEY `index_organizations_on_ancestry` (`ancestry`)
) ENGINE=InnoDB AUTO_INCREMENT=5380 DEFAULT CHARSET=utf8;

CREATE TABLE `phone_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT NULL,
  `extension` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_phone_numbers_on_person_id_and_number` (`person_id`,`number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `plugin_schema_info` (
  `plugin_name` varchar(255) DEFAULT NULL,
  `version` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `profile_pictures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `uploaded_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_profile_pictures_on_person_id` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=125 DEFAULT CHARSET=utf8;

CREATE TABLE `questionnaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `rails_admin_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `item` int(11) DEFAULT NULL,
  `table` varchar(255) DEFAULT NULL,
  `month` smallint(6) DEFAULT NULL,
  `year` bigint(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_histories_on_item_and_table_and_month_and_year` (`item`,`table`,`month`,`year`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

CREATE TABLE `rails_crons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `command` text,
  `start` int(11) DEFAULT NULL,
  `finish` int(11) DEFAULT NULL,
  `every` int(11) DEFAULT NULL,
  `concurrent` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `received_sms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(255) DEFAULT NULL,
  `carrier` varchar(255) DEFAULT NULL,
  `shortcode` varchar(255) DEFAULT NULL,
  `message` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `person_id` varchar(255) DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `followed_up` tinyint(1) DEFAULT '0',
  `assigned_to_id` int(11) DEFAULT NULL,
  `response_count` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `interactive` tinyint(1) DEFAULT '0',
  `sms_keyword_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `rejoicables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `followup_comment_id` int(11) DEFAULT NULL,
  `what` enum('spiritual_conversation','prayed_to_receive','gospel_presentation') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rideshare_event` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `conference_id` int(11) DEFAULT NULL,
  `event_name` varchar(50) DEFAULT NULL,
  `password` varchar(50) NOT NULL,
  `email_content` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

CREATE TABLE `rideshare_ride` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `driver_ride_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `address1` varchar(50) NOT NULL,
  `address2` varchar(50) NOT NULL,
  `address3` varchar(50) NOT NULL,
  `address4` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) NOT NULL,
  `zip` varchar(20) NOT NULL,
  `country` varchar(50) NOT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `contact_method` enum('text','email','phone') DEFAULT NULL,
  `number_passengers` tinyint(4) DEFAULT NULL,
  `drive_willingness` tinyint(4) DEFAULT NULL,
  `depart_time` time DEFAULT NULL,
  `special_info` text,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `drivewillingness` (`drive_willingness`),
  KEY `fk_eventID` (`event_id`),
  KEY `fk_driverID` (`driver_ride_id`),
  KEY `fk_personID` (`person_id`)
) ENGINE=MyISAM AUTO_INCREMENT=567 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `school_years` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `level` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

CREATE TABLE `sent_sms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) DEFAULT NULL,
  `recipient` varchar(255) DEFAULT NULL,
  `reports` text,
  `moonshado_claimcheck` varchar(255) DEFAULT NULL,
  `sent_via` varchar(255) DEFAULT NULL,
  `recieved_sms_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `si_answer_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `question_sheet_id` (`question_sheet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer_sheet_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `value` text,
  `short_value` varchar(255) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_si_answers_on_short_value` (`short_value`),
  KEY `question_id` (`question_id`),
  KEY `answer_sheet_id` (`answer_sheet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_applies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sleeve_id` int(11) NOT NULL,
  `applicant_id` int(11) NOT NULL,
  `status` varchar(36) NOT NULL,
  `created_at` datetime NOT NULL,
  `submitted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_si_applies_on_status` (`status`),
  KEY `index_si_applies_on_submitted_at` (`submitted_at`),
  KEY `applicant_id` (`applicant_id`),
  KEY `sleeve_id` (`sleeve_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_apply_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `apply_id` int(11) NOT NULL,
  `sleeve_sheet_id` int(11) NOT NULL,
  `answer_sheet_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `apply_id` (`apply_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_character_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `apply_id` int(11) NOT NULL,
  `sleeve_sheet_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `months_known` int(11) DEFAULT NULL,
  `status` varchar(36) NOT NULL,
  `token` varchar(255) NOT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `email_sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_si_character_references_on_token` (`token`),
  KEY `apply_id` (`apply_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='InnoDB free: 914432 kB';

CREATE TABLE `si_conditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `trigger_id` int(11) NOT NULL,
  `expression` varchar(255) NOT NULL,
  `toggle_page_id` int(11) NOT NULL,
  `toggle_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `trigger_id` (`trigger_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `page_id` int(11) NOT NULL,
  `kind` varchar(40) NOT NULL,
  `style` varchar(40) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `content` text,
  `required` tinyint(1) DEFAULT NULL,
  `slug` varchar(36) DEFAULT NULL,
  `position` int(11) NOT NULL,
  `is_confidential` tinyint(1) DEFAULT '0',
  `source` varchar(255) DEFAULT NULL,
  `value_xpath` varchar(255) DEFAULT NULL,
  `text_xpath` varchar(255) DEFAULT NULL,
  `object_name` varchar(255) DEFAULT NULL,
  `attribute_name` varchar(255) DEFAULT NULL,
  `question_grid_id` int(11) DEFAULT NULL,
  `cols` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_si_elements_on_slug` (`slug`),
  KEY `index_si_elements_on_question_sheet_id_and_position_and_page_id` (`question_sheet_id`,`position`,`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `content` text,
  `enabled` tinyint(1) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `label` varchar(100) NOT NULL,
  `number` int(11) NOT NULL,
  `no_cache` tinyint(1) DEFAULT '0',
  `hidden` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `page_number` (`question_sheet_id`,`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `apply_id` int(11) NOT NULL,
  `payment_type` varchar(255) DEFAULT NULL,
  `amount` varchar(255) DEFAULT NULL,
  `payment_account_no` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `auth_code` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `apply_id` (`apply_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_question_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(60) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(255) NOT NULL,
  `user_class` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_sleeve_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sleeve_id` int(11) NOT NULL,
  `question_sheet_id` int(11) NOT NULL,
  `title` varchar(60) NOT NULL,
  `assign_to` varchar(36) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_sleeves` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(60) NOT NULL,
  `slug` varchar(36) DEFAULT NULL,
  `fee_amount` decimal(9,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_si_sleeves_on_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `si_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ssm_id` int(11) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ssm_id` (`ssm_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `simplesecuritymanager_user` (
  `userID` int(10) NOT NULL AUTO_INCREMENT,
  `globallyUniqueID` varchar(80) DEFAULT NULL,
  `username` varchar(80) NOT NULL,
  `password` varchar(80) DEFAULT NULL,
  `passwordQuestion` varchar(200) DEFAULT NULL,
  `passwordAnswer` varchar(200) DEFAULT NULL,
  `lastFailure_deprecated` datetime DEFAULT NULL,
  `lastFailureCnt_deprecated` int(10) DEFAULT NULL,
  `lastLogin` datetime DEFAULT NULL,
  `createdOn` datetime DEFAULT NULL,
  `emailVerified_deprecated` tinyint(1) NOT NULL DEFAULT '0',
  `remember_token` varchar(255) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `developer` tinyint(1) DEFAULT NULL,
  `facebook_hash` varchar(255) DEFAULT NULL,
  `facebook_username` varchar(255) DEFAULT NULL,
  `fb_user_id` bigint(20) DEFAULT NULL,
  `password_plain` varchar(255) DEFAULT NULL,
  `password_reset_key` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `encrypted_password` varchar(255) DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`userID`),
  UNIQUE KEY `CK_simplesecuritymanager_user_username` (`username`),
  UNIQUE KEY `globallyUniqueID` (`globallyUniqueID`),
  UNIQUE KEY `index_simplesecuritymanager_user_on_email` (`email`),
  KEY `index_simplesecuritymanager_user_on_fb_user_id` (`fb_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1535270 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_children` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `birthday` datetime DEFAULT NULL,
  `passport_no` varchar(50) DEFAULT NULL,
  `person_id` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_personID` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_columns` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `column_type` varchar(20) NOT NULL,
  `select_clause` varchar(7000) NOT NULL,
  `where_clause` varchar(255) DEFAULT NULL,
  `update_clause` varchar(2000) DEFAULT NULL,
  `table_clause` varchar(100) DEFAULT NULL,
  `show_in_directory` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `writeable` tinyint(3) unsigned NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `maxlength` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=158 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_enum_values` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sitrack_column_id` int(10) unsigned NOT NULL,
  `value` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `position` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sitrack_enum_values_on_sitrack_column_id` (`sitrack_column_id`)
) ENGINE=InnoDB AUTO_INCREMENT=131 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_feeds` (
  `feed` varchar(50) NOT NULL,
  `lastRun` datetime NOT NULL,
  `numImported` int(10) DEFAULT NULL,
  KEY `IX_sitrack_Feeds` (`lastRun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_forms` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `approver_id` int(10) NOT NULL,
  `type` varchar(50) NOT NULL,
  `current_years_salary` int(11) DEFAULT NULL,
  `previous_years_salary` int(11) DEFAULT NULL,
  `additional_salary` int(11) DEFAULT NULL,
  `adoption` int(11) DEFAULT NULL,
  `counseling` int(11) DEFAULT NULL,
  `childrens_expenses` int(11) DEFAULT NULL,
  `college` int(11) DEFAULT NULL,
  `private_school` int(11) DEFAULT NULL,
  `graduate_studies` int(11) DEFAULT NULL,
  `auto_purchase` int(11) DEFAULT NULL,
  `settling_in_expenses` int(11) DEFAULT NULL,
  `reimbursable_expenses` int(11) DEFAULT NULL,
  `tax_rate` int(11) DEFAULT NULL,
  `date_of_change` datetime DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `reopen_as` varchar(100) DEFAULT NULL,
  `freeze_start` datetime DEFAULT NULL,
  `freeze_end` datetime DEFAULT NULL,
  `change_assignment_from_team` varchar(100) DEFAULT NULL,
  `change_assignment_from_location` varchar(100) DEFAULT NULL,
  `change_assignment_to_team` varchar(100) DEFAULT NULL,
  `change_assignment_to_location` varchar(100) DEFAULT NULL,
  `restint_location` varchar(100) DEFAULT NULL,
  `departure_date_certainty` varchar(100) DEFAULT NULL,
  `hours_per_week` int(11) DEFAULT NULL,
  `other_explanation` varchar(1000) DEFAULT NULL,
  `new_staff_training_date` datetime DEFAULT NULL,
  `payroll_action` varchar(100) DEFAULT NULL,
  `payroll_reason` varchar(100) DEFAULT NULL,
  `hrd` varchar(100) DEFAULT NULL,
  `spouse_name` varchar(100) DEFAULT NULL,
  `spouse_transitioning` tinyint(1) DEFAULT NULL,
  `salary_reason` varchar(1000) DEFAULT NULL,
  `annual_salary` int(11) DEFAULT NULL,
  `hr_si_application_id` int(11) NOT NULL,
  `additional_notes` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10592 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_mpd` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `application_id` int(10) DEFAULT NULL,
  `person_id` int(10) DEFAULT NULL,
  `coachName` varchar(50) DEFAULT NULL,
  `coachPhone` varchar(20) DEFAULT NULL,
  `coachCell` varchar(20) DEFAULT NULL,
  `coachEmail` varchar(50) DEFAULT NULL,
  `monthlyGoal` int(10) DEFAULT NULL,
  `oneTimeGoal` int(10) DEFAULT NULL,
  `monthlyRaised` int(10) DEFAULT NULL,
  `oneTimeRaised` int(10) DEFAULT NULL,
  `totalGoal` int(10) DEFAULT NULL,
  `totalRaised` int(10) DEFAULT NULL,
  `percentRaised` int(10) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `goalYear` varchar(4) DEFAULT NULL,
  `salary` int(10) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `account_balance` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_personID` (`person_id`),
  KEY `fk_applicationID` (`application_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4199 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_queries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `owner` int(10) NOT NULL,
  `persons` longtext NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB AUTO_INCREMENT=364 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_saved_criteria` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `owner` int(10) NOT NULL,
  `criteria` longtext NOT NULL,
  `saved` tinyint(3) NOT NULL DEFAULT '0',
  `options` mediumtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `owner_sitrack_SavedCriteria` (`owner`),
  KEY `index_sitrack_saved_criteria_on_saved` (`saved`)
) ENGINE=InnoDB AUTO_INCREMENT=50677 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_session_values` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sitrack_session_id` int(10) NOT NULL,
  `attrib` varchar(50) DEFAULT NULL,
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_sitrack_session_values_on_attrib` (`attrib`),
  KEY `sitrack_session_id` (`sitrack_session_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=73652 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitrack_user_id` int(10) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sitrack_sessions_on_sitrack_user_id` (`sitrack_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=276 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_tracking` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `application_id` int(10) DEFAULT NULL,
  `person_id` int(10) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `internType` varchar(30) DEFAULT NULL,
  `tenure` varchar(50) DEFAULT NULL,
  `ssn` varchar(50) DEFAULT NULL,
  `teamLeader` tinyint(3) DEFAULT NULL,
  `caringRegion` varchar(50) DEFAULT NULL,
  `passportNo` varchar(20) DEFAULT NULL,
  `asgYear` varchar(9) DEFAULT NULL,
  `asgTeam` varchar(50) DEFAULT NULL,
  `asgCity` varchar(50) DEFAULT NULL,
  `asgState` varchar(50) DEFAULT NULL,
  `asgCountry` varchar(50) DEFAULT NULL,
  `asgContinent` varchar(50) DEFAULT NULL,
  `asgSchool` varchar(90) DEFAULT NULL,
  `spouseName` varchar(50) DEFAULT NULL,
  `departureDate` datetime DEFAULT NULL,
  `terminationDate` datetime DEFAULT NULL,
  `notes` longtext,
  `changedByPerson` int(10) DEFAULT NULL,
  `appReadyDate` datetime DEFAULT NULL,
  `evaluator` varchar(50) DEFAULT NULL,
  `evalStartDate` datetime DEFAULT NULL,
  `preADate` datetime DEFAULT NULL,
  `medPsychDate` datetime DEFAULT NULL,
  `finalADate` datetime DEFAULT NULL,
  `placementComments` longtext,
  `expectReturnDate` datetime DEFAULT NULL,
  `confirmReturnDate` datetime DEFAULT NULL,
  `maidenName` varchar(50) DEFAULT NULL,
  `sendLane` varchar(20) DEFAULT NULL,
  `mpdEmailSent` datetime DEFAULT NULL,
  `kickoffNotes` longtext,
  `addFormSent` datetime DEFAULT NULL,
  `updateFormSent` datetime DEFAULT NULL,
  `fieldCoach` varchar(50) DEFAULT NULL,
  `medPsychSent` datetime DEFAULT NULL,
  `needsDebtCheck` tinyint(3) DEFAULT NULL,
  `acceptanceLetter` datetime DEFAULT NULL,
  `evalDocsRec` datetime DEFAULT NULL,
  `oneCard` tinyint(3) DEFAULT NULL,
  `playbookSent` datetime DEFAULT NULL,
  `kickoffRoomate` varchar(50) DEFAULT NULL,
  `futurePlan` varchar(50) DEFAULT NULL,
  `mpReceived` datetime DEFAULT NULL,
  `physicalSent` datetime DEFAULT NULL,
  `physicalReceived` datetime DEFAULT NULL,
  `evalType` varchar(10) DEFAULT NULL,
  `preIKWSent` datetime DEFAULT NULL,
  `debt` varchar(50) DEFAULT NULL,
  `restint` longtext,
  `evalSummary` datetime DEFAULT NULL,
  `returnDate` datetime DEFAULT NULL,
  `effectiveChange` datetime DEFAULT NULL,
  `addForm` datetime DEFAULT NULL,
  `salaryForm` datetime DEFAULT NULL,
  `acosForm` datetime DEFAULT NULL,
  `joinStaffForm` datetime DEFAULT NULL,
  `readyDate` datetime DEFAULT NULL,
  `additionalSalaryForm` datetime DEFAULT NULL,
  `miniPref` varchar(50) DEFAULT NULL,
  `birthCity` varchar(50) DEFAULT NULL,
  `birthState` varchar(50) DEFAULT NULL,
  `ikw_location` varchar(100) DEFAULT NULL,
  `summer_preference` varchar(100) DEFAULT NULL,
  `summer_assignment` varchar(100) DEFAULT NULL,
  `trainer` varchar(255) DEFAULT NULL,
  `trainer_contact` mediumtext,
  `vonage` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `send_dept` int(11) DEFAULT NULL,
  `regionOfOrigin` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `asgTeam` (`asgTeam`),
  KEY `caringRegion` (`caringRegion`),
  KEY `interntype` (`internType`),
  KEY `status` (`status`),
  KEY `teamLeader` (`teamLeader`),
  KEY `tenure` (`tenure`),
  KEY `fk_applicationID` (`application_id`),
  KEY `fk_personID` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8730 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ssm_id` int(10) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by` int(10) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sitrack_users_on_ssm_id` (`ssm_id`)
) ENGINE=InnoDB AUTO_INCREMENT=402 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_view_columns` (
  `sitrack_view_id` int(10) NOT NULL DEFAULT '0',
  `sitrack_column_id` int(10) NOT NULL DEFAULT '0',
  `position` int(10) DEFAULT '0',
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `sitrack_view_id` (`sitrack_view_id`),
  KEY `sitrack_column_id` (`sitrack_column_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22474 DEFAULT CHARSET=utf8;

CREATE TABLE `sitrack_views` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sitrack_user_id` int(10) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uuid` (`sitrack_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2600 DEFAULT CHARSET=utf8;

CREATE TABLE `sms_carriers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `moonshado_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `recieved` int(11) DEFAULT '0',
  `sent_emails` int(11) DEFAULT '0',
  `bounced_emails` int(11) DEFAULT '0',
  `sent_sms` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `sms_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `keyword` varchar(255) DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `chartfield` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `explanation` text,
  `state` varchar(255) DEFAULT NULL,
  `initial_response` varchar(140) DEFAULT 'Hi! Thanks for checking out Cru. Visit {{ link }} to get more involved.',
  `post_survey_message` text,
  `event_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `sn_campus_involvements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `campus_id` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `added_by_id` int(11) DEFAULT NULL,
  `graduation_date` date DEFAULT NULL,
  `school_year_id` int(11) DEFAULT NULL,
  `major` varchar(255) DEFAULT NULL,
  `minor` varchar(255) DEFAULT NULL,
  `last_history_update_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_campus_involvements_on_ministry_id` (`ministry_id`),
  KEY `index_sn_campus_involvements_on_campus_id` (`campus_id`),
  KEY `index_sn_campus_involvements_on_person_id` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1072 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_campus_ministry_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `campus_id` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sn_columns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `update_clause` varchar(255) DEFAULT NULL,
  `from_clause` varchar(255) DEFAULT NULL,
  `select_clause` text,
  `column_type` varchar(255) DEFAULT NULL,
  `writeable` varchar(255) DEFAULT NULL,
  `join_clause` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `source_model` varchar(255) DEFAULT NULL,
  `source_column` varchar(255) DEFAULT NULL,
  `foreign_key` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_correspondence_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `overdue_lifespan` int(11) DEFAULT NULL,
  `expiry_lifespan` int(11) DEFAULT NULL,
  `actions_now_task` varchar(255) DEFAULT NULL,
  `actions_overdue_task` varchar(255) DEFAULT NULL,
  `actions_followup_task` varchar(255) DEFAULT NULL,
  `redirect_params` text,
  `redirect_target_id_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_correspondences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `correspondence_type_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `receipt` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `visited` date DEFAULT NULL,
  `completed` date DEFAULT NULL,
  `overdue_at` date DEFAULT NULL,
  `expire_at` date DEFAULT NULL,
  `token_params` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_correspondences_on_receipt` (`receipt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_custom_attributes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ministry_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `value_type` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_custom_attributes_on_ministry_id` (`ministry_id`),
  KEY `index_sn_custom_attributes_on_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_custom_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `custom_attribute_id` int(11) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sn_custom_values_on_person_id_and_custom_attribute_id` (`person_id`,`custom_attribute_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_dorms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campus_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `campus_id` (`campus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `correspondence_type_id` int(11) DEFAULT NULL,
  `outcome_type` varchar(255) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `from` varchar(255) NOT NULL,
  `bcc` varchar(255) DEFAULT NULL,
  `cc` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  `template` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) DEFAULT NULL,
  `body` text,
  `people_ids` text,
  `missing_address_ids` text,
  `search_id` int(11) DEFAULT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_free_times` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `start_time` int(11) DEFAULT NULL,
  `end_time` int(11) DEFAULT NULL,
  `day_of_week` int(11) DEFAULT NULL,
  `timetable_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `css_class` varchar(255) DEFAULT NULL,
  `weight` decimal(4,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1288 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_group_involvements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `level` varchar(255) DEFAULT NULL,
  `requested` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_group` (`person_id`,`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_group_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ministry_id` int(11) DEFAULT NULL,
  `group_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `mentor_priority` tinyint(1) DEFAULT NULL,
  `public` tinyint(1) DEFAULT NULL,
  `unsuitability_leader` int(11) DEFAULT NULL,
  `unsuitability_coleader` int(11) DEFAULT NULL,
  `unsuitability_participant` int(11) DEFAULT NULL,
  `collection_group_name` varchar(255) DEFAULT '{{campus}} interested in a {{group_type}}',
  `has_collection_groups` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `address_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `dorm_id` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `campus_id` int(11) DEFAULT NULL,
  `start_time` int(11) DEFAULT NULL,
  `end_time` int(11) DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `group_type_id` int(11) DEFAULT NULL,
  `needs_approval` tinyint(1) DEFAULT NULL,
  `semester_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_groups_on_ministry_id` (`ministry_id`),
  KEY `index_sn_groups_on_campus_id` (`campus_id`),
  KEY `index_sn_groups_on_dorm_id` (`dorm_id`),
  KEY `index_sn_groups_on_semester_id` (`semester_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `filename` varchar(255) DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_involvement_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `campus_id` int(11) DEFAULT NULL,
  `school_year_id` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `ministry_role_id` int(11) DEFAULT NULL,
  `campus_involvement_id` int(11) DEFAULT NULL,
  `ministry_involvement_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_ministries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ministries_count` int(11) DEFAULT NULL,
  `lane` varchar(255) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `isActive` varchar(255) DEFAULT NULL,
  `hasMultiRegionalAccess` varchar(255) DEFAULT NULL,
  `dept_id` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `strategy_id` int(11) DEFAULT NULL,
  `legacy_regionalteam_id` int(11) DEFAULT NULL,
  `legacy_locallevel_id` int(11) DEFAULT NULL,
  `legacy_activity_id` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_ministries_on_parent_id` (`parent_id`),
  KEY `index_sn_ministries_on_lft` (`lft`),
  KEY `index_sn_ministries_on_rgt` (`rgt`)
) ENGINE=InnoDB AUTO_INCREMENT=6904 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_ministry_campuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ministry_id` int(11) DEFAULT NULL,
  `campus_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ministry_campus` (`ministry_id`,`campus_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13781 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_ministry_involvements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `admin` tinyint(1) DEFAULT NULL,
  `ministry_role_id` int(11) DEFAULT NULL,
  `responsible_person_id` int(11) DEFAULT NULL,
  `last_history_update_date` date DEFAULT NULL,
  `is_people_soft` tinyint(1) DEFAULT NULL,
  `is_leader` tinyint(1) DEFAULT NULL,
  `legacy_missional_team_member_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_ministry` (`person_id`,`ministry_id`),
  KEY `index_sn_ministry_involvements_on_ministry_id` (`ministry_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3924 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_ministry_role_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_id` int(11) DEFAULT NULL,
  `ministry_role_id` int(11) DEFAULT NULL,
  `created_at` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_ministry_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ministry_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `involved` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_sn_ministry_roles_on_ministry_id` (`ministry_id`)
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `message` text,
  `group_id` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `sticky` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `staff` tinyint(1) DEFAULT NULL,
  `students` tinyint(1) DEFAULT NULL,
  `featured` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `sn_news_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `comment` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sn_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(255) DEFAULT NULL,
  `controller` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_person_news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `news_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `featured` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_person_news_on_person_id` (`person_id`),
  KEY `index_sn_person_news_on_news_id` (`news_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

CREATE TABLE `sn_searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `options` text,
  `query` text,
  `tables` text,
  `saved` tinyint(1) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `order` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=203 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_semesters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `year_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_semesters_on_year_id` (`year_id`),
  KEY `index_sn_semesters_on_start_date` (`start_date`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

CREATE TABLE `sn_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3793 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_timetables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `sn_timetables_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `ministry_person` (`personID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_training_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `training_question_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `approved_by` varchar(255) DEFAULT NULL,
  `completed_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_training_answers_on_person_id` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_training_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_training_categories_on_ministry_id` (`ministry_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_training_question_activations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ministry_id` int(11) DEFAULT NULL,
  `training_question_id` int(11) DEFAULT NULL,
  `mandate` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_training_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ministry_id` int(11) DEFAULT NULL,
  `training_category_id` int(11) DEFAULT NULL,
  `activity` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_training_questions_on_ministry_id` (`ministry_id`),
  KEY `index_sn_training_questions_on_training_category_id` (`training_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_user_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `pass` text,
  PRIMARY KEY (`id`),
  KEY `index_sn_user_codes_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `sn_user_group_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_id` int(11) DEFAULT NULL,
  `user_group_id` int(11) DEFAULT NULL,
  `created_at` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_user_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  `ministry_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_user_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `user_group_id` int(11) DEFAULT NULL,
  `created_at` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sn_view_columns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `view_id` int(11) DEFAULT NULL,
  `column_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_view_columns_on_view_id_and_column_id` (`view_id`,`column_id`),
  KEY `index_sn_view_columns_on_column_id` (`column_id`)
) ENGINE=InnoDB AUTO_INCREMENT=433 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(2000) DEFAULT NULL,
  `select_clause` text,
  `tables_clause` text,
  `ministry_id` int(11) DEFAULT NULL,
  `default_view` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sn_views_on_ministry_id` (`ministry_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8;

CREATE TABLE `sn_years` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `desc` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

CREATE TABLE `sp_answer_sheet_question_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer_sheet_id` int(11) DEFAULT NULL,
  `question_sheet_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sp_answer_sheet_question_sheets_on_answer_sheet_id` (`answer_sheet_id`),
  KEY `index_sp_answer_sheet_question_sheets_on_question_sheet_id` (`question_sheet_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5708 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_answer_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sp_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer_sheet_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `value` text,
  `short_value` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sp_answers_on_answer_sheet_id` (`answer_sheet_id`),
  KEY `index_sp_answers_on_question_id` (`question_id`),
  KEY `index_sp_answers_on_short_value` (`short_value`),
  KEY `index_on_as_and_q` (`question_id`,`answer_sheet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sp_application_moves` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `application_id` int(11) DEFAULT NULL,
  `old_project_id` int(11) DEFAULT NULL,
  `new_project_id` int(11) DEFAULT NULL,
  `moved_by_person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `designation_number` int(11) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `preference1_id` int(11) DEFAULT NULL,
  `preference2_id` int(11) DEFAULT NULL,
  `preference3_id` int(11) DEFAULT NULL,
  `preference4_id` int(11) DEFAULT NULL,
  `preference5_id` int(11) DEFAULT NULL,
  `current_project_queue_id` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `old_id` int(10) unsigned DEFAULT NULL,
  `apply_for_leadership` tinyint(1) DEFAULT NULL,
  `withdrawn_at` datetime DEFAULT NULL,
  `su_code` varchar(255) DEFAULT NULL,
  `applicant_notified` tinyint(1) DEFAULT NULL,
  `account_balance` int(11) DEFAULT NULL,
  `accepted_at` datetime DEFAULT NULL,
  `previous_status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sp_applications_on_person_id` (`person_id`),
  KEY `index_sp_applications_on_year` (`year`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `sp_applications_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `sp_projects` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=57808 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_conditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `trigger_id` int(11) NOT NULL,
  `expression` varchar(255) NOT NULL,
  `toggle_page_id` int(11) NOT NULL,
  `toggle_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sp_donations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `designation_number` int(11) NOT NULL,
  `amount` double NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sp_donations_designation_number_index` (`designation_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sp_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kind` varchar(40) NOT NULL,
  `style` varchar(40) DEFAULT NULL,
  `label` text,
  `content` text,
  `required` tinyint(1) DEFAULT NULL,
  `slug` varchar(36) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `object_name` varchar(255) DEFAULT NULL,
  `attribute_name` varchar(255) DEFAULT NULL,
  `source` varchar(255) DEFAULT NULL,
  `value_xpath` varchar(255) DEFAULT NULL,
  `text_xpath` varchar(255) DEFAULT NULL,
  `question_grid_id` int(11) DEFAULT NULL,
  `cols` varchar(255) DEFAULT NULL,
  `is_confidential` tinyint(1) DEFAULT NULL,
  `total_cols` varchar(255) DEFAULT NULL,
  `css_id` varchar(255) DEFAULT NULL,
  `css_class` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `related_question_sheet_id` int(11) DEFAULT NULL,
  `conditional_id` int(11) DEFAULT NULL,
  `tooltip` text,
  `hide_label` tinyint(1) DEFAULT '0',
  `hide_option_labels` tinyint(1) DEFAULT '0',
  `max_length` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sp_elements_on_slug` (`slug`),
  KEY `index_sp_elements_on_question_sheet_id_and_position_and_page_id` (`position`)
) ENGINE=InnoDB AUTO_INCREMENT=1727 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_email_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(1000) NOT NULL,
  `content` text,
  `enabled` tinyint(1) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sp_email_templates_on_name` (`name`(255))
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_evaluations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `application_id` int(11) NOT NULL,
  `spiritual_maturity` int(11) DEFAULT '0',
  `teachability` int(11) DEFAULT '0',
  `leadership` int(11) DEFAULT '0',
  `stability` int(11) DEFAULT '0',
  `good_evangelism` int(11) DEFAULT '0',
  `reason` int(11) DEFAULT '0',
  `social_maturity` int(11) DEFAULT '0',
  `ccc_involvement` int(11) DEFAULT '0',
  `charismatic` tinyint(1) DEFAULT '0',
  `morals` tinyint(1) DEFAULT '0',
  `drugs` tinyint(1) DEFAULT '0',
  `bad_evangelism` tinyint(1) DEFAULT '0',
  `authority` tinyint(1) DEFAULT '0',
  `eating` tinyint(1) DEFAULT '0',
  `comments` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16752 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_gospel_in_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_ministry_focuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_ministry_focuses_projects` (
  `sp_project_id` int(11) NOT NULL DEFAULT '0',
  `sp_ministry_focus_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`sp_project_id`,`sp_ministry_focus_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sp_page_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `page_id` int(11) DEFAULT NULL,
  `element_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `page_id` (`page_id`),
  KEY `element_id` (`element_id`),
  CONSTRAINT `sp_page_elements_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `sp_pages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sp_page_elements_ibfk_2` FOREIGN KEY (`element_id`) REFERENCES `sp_elements` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3843 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_sheet_id` int(11) NOT NULL,
  `label` varchar(100) NOT NULL,
  `number` int(11) DEFAULT NULL,
  `no_cache` tinyint(1) DEFAULT '0',
  `hidden` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `page_number` (`question_sheet_id`,`number`),
  CONSTRAINT `sp_pages_ibfk_1` FOREIGN KEY (`question_sheet_id`) REFERENCES `sp_question_sheets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=689 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `application_id` int(11) DEFAULT NULL,
  `payment_type` varchar(255) DEFAULT NULL,
  `amount` varchar(255) DEFAULT NULL,
  `payment_account_no` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `auth_code` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16141 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_project_gospel_in_actions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `gospel_in_action_id` int(11) DEFAULT NULL,
  `project_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `gospel_in_action_id` (`gospel_in_action_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `sp_project_gospel_in_actions_ibfk_1` FOREIGN KEY (`gospel_in_action_id`) REFERENCES `sp_gospel_in_actions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sp_project_gospel_in_actions_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `sp_projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_project_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pd_id` int(11) DEFAULT NULL,
  `apd_id` int(11) DEFAULT NULL,
  `opd_id` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(60) DEFAULT NULL,
  `aoa` varchar(50) DEFAULT NULL,
  `display_location` varchar(100) DEFAULT NULL,
  `primary_partner` varchar(100) DEFAULT NULL,
  `secondary_partner` varchar(100) DEFAULT NULL,
  `partner_region_only` tinyint(1) DEFAULT NULL,
  `report_stats_to` varchar(50) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `weeks` int(11) DEFAULT NULL,
  `primary_ministry_focus_id` int(11) DEFAULT NULL,
  `job` tinyint(1) DEFAULT NULL,
  `description` text,
  `operating_business_unit` varchar(50) DEFAULT NULL,
  `operating_operating_unit` varchar(50) DEFAULT NULL,
  `operating_department` varchar(50) DEFAULT NULL,
  `operating_project` varchar(50) DEFAULT NULL,
  `operating_designation` varchar(50) DEFAULT NULL,
  `scholarship_business_unit` varchar(50) DEFAULT NULL,
  `scholarship_operating_unit` varchar(50) DEFAULT NULL,
  `scholarship_department` varchar(50) DEFAULT NULL,
  `scholarship_project` varchar(50) DEFAULT NULL,
  `scholarship_designation` varchar(50) DEFAULT NULL,
  `staff_cost` int(11) DEFAULT NULL,
  `intern_cost` int(11) DEFAULT NULL,
  `student_cost` int(11) DEFAULT NULL,
  `departure_city` varchar(60) DEFAULT NULL,
  `date_of_departure` datetime DEFAULT NULL,
  `destination_city` varchar(60) DEFAULT NULL,
  `date_of_return` datetime DEFAULT NULL,
  `in_country_contact` text,
  `project_contact_name` varchar(50) DEFAULT NULL,
  `project_contact_role` varchar(40) DEFAULT NULL,
  `project_contact_phone` varchar(20) DEFAULT NULL,
  `project_contact_email` varchar(100) DEFAULT NULL,
  `max_student_men_applicants` int(11) NOT NULL DEFAULT '0',
  `max_student_women_applicants` int(11) NOT NULL DEFAULT '0',
  `housing_capacity_men` int(11) DEFAULT NULL,
  `housing_capacity_women` int(11) DEFAULT NULL,
  `ideal_staff_men` int(11) NOT NULL DEFAULT '0',
  `ideal_staff_women` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `current_students_men` int(11) DEFAULT '0',
  `current_students_women` int(11) DEFAULT '0',
  `current_applicants_men` int(11) DEFAULT '0',
  `current_applicants_women` int(11) DEFAULT '0',
  `year` int(11) DEFAULT NULL,
  `coordinator_id` int(11) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL,
  `project_status` varchar(255) DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `url` varchar(1024) DEFAULT NULL,
  `url_title` varchar(255) DEFAULT NULL,
  `ds_project_code` varchar(50) DEFAULT NULL,
  `sp_project_id` int(11) DEFAULT NULL,
  `show_on_website` tinyint(1) DEFAULT '1',
  `apply_by_date` datetime DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `use_provided_application` tinyint(1) DEFAULT '1',
  `tertiary_partner` varchar(255) DEFAULT NULL,
  `staff_start_date` date DEFAULT NULL,
  `staff_end_date` date DEFAULT NULL,
  `project_contact2_name` varchar(255) DEFAULT NULL,
  `project_contact2_role` varchar(255) DEFAULT NULL,
  `project_contact2_phone` varchar(255) DEFAULT NULL,
  `project_contact2_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sp_project_versions_on_name` (`name`),
  KEY `index_sp_project_versions_on_city` (`city`),
  KEY `index_sp_project_versions_on_country` (`country`),
  KEY `index_sp_project_versions_on_primary_partner` (`primary_partner`),
  KEY `index_sp_project_versions_on_secondary_partner` (`secondary_partner`),
  KEY `index_sp_project_versions_on_aoa` (`aoa`),
  KEY `index_sp_project_versions_on_start_date` (`start_date`),
  KEY `index_sp_project_versions_on_end_date` (`end_date`),
  KEY `index_sp_project_versions_on_year` (`year`),
  KEY `index_sp_project_versions_on_primary_ministry_focus_id` (`primary_ministry_focus_id`),
  KEY `index_sp_project_versions_on_sp_project_id` (`sp_project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=183777 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pd_id` int(11) DEFAULT NULL,
  `apd_id` int(11) DEFAULT NULL,
  `opd_id` int(11) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `country` varchar(60) DEFAULT NULL,
  `aoa` varchar(50) DEFAULT NULL,
  `display_location` varchar(100) DEFAULT NULL,
  `primary_partner` varchar(100) DEFAULT NULL,
  `secondary_partner` varchar(100) DEFAULT NULL,
  `partner_region_only` tinyint(1) DEFAULT NULL,
  `report_stats_to` varchar(50) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `weeks` int(11) DEFAULT NULL,
  `primary_ministry_focus_id` int(11) DEFAULT NULL,
  `job` tinyint(1) DEFAULT NULL,
  `description` text,
  `operating_business_unit` varchar(50) DEFAULT NULL,
  `operating_operating_unit` varchar(50) DEFAULT NULL,
  `operating_department` varchar(50) DEFAULT NULL,
  `operating_project` varchar(50) DEFAULT NULL,
  `operating_designation` varchar(50) DEFAULT NULL,
  `scholarship_business_unit` varchar(50) DEFAULT NULL,
  `scholarship_operating_unit` varchar(50) DEFAULT NULL,
  `scholarship_department` varchar(50) DEFAULT NULL,
  `scholarship_project` varchar(50) DEFAULT NULL,
  `scholarship_designation` varchar(50) DEFAULT NULL,
  `staff_cost` int(11) DEFAULT NULL,
  `intern_cost` int(11) DEFAULT NULL,
  `student_cost` int(11) DEFAULT NULL,
  `departure_city` varchar(60) DEFAULT NULL,
  `date_of_departure` date DEFAULT NULL,
  `destination_city` varchar(60) DEFAULT NULL,
  `date_of_return` date DEFAULT NULL,
  `in_country_contact` text,
  `project_contact_name` varchar(50) DEFAULT NULL,
  `project_contact_role` varchar(40) DEFAULT NULL,
  `project_contact_phone` varchar(20) DEFAULT NULL,
  `project_contact_email` varchar(100) DEFAULT NULL,
  `max_student_men_applicants` int(11) NOT NULL DEFAULT '60',
  `max_student_women_applicants` int(11) NOT NULL DEFAULT '60',
  `max_accepted_men` int(11) DEFAULT NULL,
  `max_accepted_women` int(11) DEFAULT NULL,
  `ideal_staff_men` int(11) NOT NULL DEFAULT '0',
  `ideal_staff_women` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `current_students_men` int(11) DEFAULT '0',
  `current_students_women` int(11) DEFAULT '0',
  `current_applicants_men` int(11) DEFAULT '0',
  `current_applicants_women` int(11) DEFAULT '0',
  `year` int(11) NOT NULL,
  `coordinator_id` int(11) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL,
  `project_status` varchar(255) DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `url` varchar(1024) DEFAULT NULL,
  `url_title` varchar(255) DEFAULT NULL,
  `ds_project_code` varchar(50) DEFAULT NULL,
  `show_on_website` tinyint(1) DEFAULT '1',
  `apply_by_date` datetime DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `use_provided_application` tinyint(1) DEFAULT '1',
  `tertiary_partner` varchar(255) DEFAULT NULL,
  `staff_start_date` date DEFAULT NULL,
  `staff_end_date` date DEFAULT NULL,
  `facebook_url` varchar(255) DEFAULT NULL,
  `blog_url` varchar(255) DEFAULT NULL,
  `blog_title` varchar(255) DEFAULT NULL,
  `project_contact2_name` varchar(255) DEFAULT NULL,
  `project_contact2_role` varchar(255) DEFAULT NULL,
  `project_contact2_phone` varchar(255) DEFAULT NULL,
  `project_contact2_email` varchar(255) DEFAULT NULL,
  `picture_file_name` varchar(255) DEFAULT NULL,
  `picture_content_type` varchar(255) DEFAULT NULL,
  `picture_file_size` int(11) DEFAULT NULL,
  `picture_updated_at` datetime DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `logo_updated_at` datetime DEFAULT NULL,
  `basic_info_question_sheet_id` int(11) DEFAULT NULL,
  `template_question_sheet_id` int(11) DEFAULT NULL,
  `project_specific_question_sheet_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sp_projects_name_index` (`name`),
  KEY `primary_partner` (`primary_partner`),
  KEY `secondary_partner` (`secondary_partner`),
  KEY `project_status` (`project_status`),
  KEY `year` (`year`)
) ENGINE=InnoDB AUTO_INCREMENT=718 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_question_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `option` varchar(50) DEFAULT NULL,
  `value` varchar(50) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=346 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_question_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(1000) NOT NULL,
  `archived` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=286 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_questionnaire_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `questionnaire_id` int(11) DEFAULT NULL,
  `page_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_references` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `applicant_answer_sheet_id` int(11) DEFAULT NULL,
  `email_sent_at` datetime DEFAULT NULL,
  `relationship` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `access_key` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_staff` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `sp_references_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `sp_elements` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=108923 DEFAULT CHARSET=latin1;

CREATE TABLE `sp_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role` varchar(50) DEFAULT NULL,
  `user_class` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_staff` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `project_id` int(11) NOT NULL,
  `type` varchar(100) NOT NULL DEFAULT '',
  `year` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_staff_type` (`project_id`,`type`,`year`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `sp_staff_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `ministry_person` (`personID`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `sp_staff_ibfk_2` FOREIGN KEY (`project_id`) REFERENCES `sp_projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6157 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) DEFAULT NULL,
  `spiritual_conversations_initiated` int(11) DEFAULT NULL,
  `gospel_shared` int(11) DEFAULT NULL,
  `received_christ` int(11) DEFAULT NULL,
  `holy_spirit_presentations` int(11) DEFAULT NULL,
  `holy_spirit_filled` int(11) DEFAULT NULL,
  `other_exposures` int(11) DEFAULT NULL,
  `involved_new_believers` int(11) DEFAULT NULL,
  `students_involved` int(11) DEFAULT NULL,
  `spiritual_multipliers` int(11) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `gospel_shared_personal` int(11) DEFAULT NULL,
  `gospel_shared_group` int(11) DEFAULT NULL,
  `gospel_shared_media` int(11) DEFAULT NULL,
  `pioneer_campuses` int(11) DEFAULT NULL,
  `key_contact_campuses` int(11) DEFAULT NULL,
  `launched_campuses` int(11) DEFAULT NULL,
  `movements_launched` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=348 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_student_quotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) DEFAULT NULL,
  `quote` text,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `sp_student_quotes_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `sp_projects` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

CREATE TABLE `sp_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ssm_id` int(11) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sp_users_ssm_id_index` (`ssm_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `sp_users_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `ministry_person` (`personID`) ON DELETE CASCADE,
  CONSTRAINT `sp_users_ibfk_2` FOREIGN KEY (`ssm_id`) REFERENCES `simplesecuritymanager_user` (`userID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6409 DEFAULT CHARSET=utf8;

CREATE TABLE `staffsite_staffsitepref` (
  `StaffSitePrefID` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL,
  `displayName` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  `fk_StaffSiteProfile` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`StaffSitePrefID`),
  KEY `index1` (`fk_StaffSiteProfile`),
  KEY `index2` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=48345 DEFAULT CHARSET=utf8;

CREATE TABLE `staffsite_staffsiteprofile` (
  `StaffSiteProfileID` int(10) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(64) DEFAULT NULL,
  `lastName` varchar(64) DEFAULT NULL,
  `userName` varchar(64) DEFAULT NULL,
  `changePassword` tinyint(1) DEFAULT NULL,
  `captureHRinfo` tinyint(1) DEFAULT NULL,
  `accountNo` varchar(64) DEFAULT NULL,
  `isStaff` tinyint(1) DEFAULT NULL,
  `email` varchar(64) DEFAULT NULL,
  `passwordQuestion` varchar(64) DEFAULT NULL,
  `passwordAnswer` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`StaffSiteProfileID`),
  KEY `index1` (`userName`)
) ENGINE=InnoDB AUTO_INCREMENT=10355 DEFAULT CHARSET=utf8;

CREATE TABLE `states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state` varchar(100) DEFAULT NULL,
  `code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8;

CREATE TABLE `summer_placement_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_teams_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('100');

INSERT INTO schema_migrations (version) VALUES ('101');

INSERT INTO schema_migrations (version) VALUES ('102');

INSERT INTO schema_migrations (version) VALUES ('103');

INSERT INTO schema_migrations (version) VALUES ('104');

INSERT INTO schema_migrations (version) VALUES ('105');

INSERT INTO schema_migrations (version) VALUES ('106');

INSERT INTO schema_migrations (version) VALUES ('107');

INSERT INTO schema_migrations (version) VALUES ('108');

INSERT INTO schema_migrations (version) VALUES ('109');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('110');

INSERT INTO schema_migrations (version) VALUES ('111');

INSERT INTO schema_migrations (version) VALUES ('112');

INSERT INTO schema_migrations (version) VALUES ('113');

INSERT INTO schema_migrations (version) VALUES ('115');

INSERT INTO schema_migrations (version) VALUES ('116');

INSERT INTO schema_migrations (version) VALUES ('117');

INSERT INTO schema_migrations (version) VALUES ('118');

INSERT INTO schema_migrations (version) VALUES ('119');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('120');

INSERT INTO schema_migrations (version) VALUES ('121');

INSERT INTO schema_migrations (version) VALUES ('122');

INSERT INTO schema_migrations (version) VALUES ('123');

INSERT INTO schema_migrations (version) VALUES ('124');

INSERT INTO schema_migrations (version) VALUES ('125');

INSERT INTO schema_migrations (version) VALUES ('126');

INSERT INTO schema_migrations (version) VALUES ('127');

INSERT INTO schema_migrations (version) VALUES ('128');

INSERT INTO schema_migrations (version) VALUES ('129');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('130');

INSERT INTO schema_migrations (version) VALUES ('131');

INSERT INTO schema_migrations (version) VALUES ('132');

INSERT INTO schema_migrations (version) VALUES ('133');

INSERT INTO schema_migrations (version) VALUES ('134');

INSERT INTO schema_migrations (version) VALUES ('135');

INSERT INTO schema_migrations (version) VALUES ('136');

INSERT INTO schema_migrations (version) VALUES ('137');

INSERT INTO schema_migrations (version) VALUES ('138');

INSERT INTO schema_migrations (version) VALUES ('139');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('140');

INSERT INTO schema_migrations (version) VALUES ('141');

INSERT INTO schema_migrations (version) VALUES ('142');

INSERT INTO schema_migrations (version) VALUES ('143');

INSERT INTO schema_migrations (version) VALUES ('144');

INSERT INTO schema_migrations (version) VALUES ('145');

INSERT INTO schema_migrations (version) VALUES ('146');

INSERT INTO schema_migrations (version) VALUES ('147');

INSERT INTO schema_migrations (version) VALUES ('148');

INSERT INTO schema_migrations (version) VALUES ('149');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('150');

INSERT INTO schema_migrations (version) VALUES ('151');

INSERT INTO schema_migrations (version) VALUES ('152');

INSERT INTO schema_migrations (version) VALUES ('153');

INSERT INTO schema_migrations (version) VALUES ('154');

INSERT INTO schema_migrations (version) VALUES ('155');

INSERT INTO schema_migrations (version) VALUES ('156');

INSERT INTO schema_migrations (version) VALUES ('157');

INSERT INTO schema_migrations (version) VALUES ('158');

INSERT INTO schema_migrations (version) VALUES ('159');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('160');

INSERT INTO schema_migrations (version) VALUES ('161');

INSERT INTO schema_migrations (version) VALUES ('162');

INSERT INTO schema_migrations (version) VALUES ('163');

INSERT INTO schema_migrations (version) VALUES ('164');

INSERT INTO schema_migrations (version) VALUES ('165');

INSERT INTO schema_migrations (version) VALUES ('166');

INSERT INTO schema_migrations (version) VALUES ('167');

INSERT INTO schema_migrations (version) VALUES ('168');

INSERT INTO schema_migrations (version) VALUES ('169');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('170');

INSERT INTO schema_migrations (version) VALUES ('171');

INSERT INTO schema_migrations (version) VALUES ('172');

INSERT INTO schema_migrations (version) VALUES ('173');

INSERT INTO schema_migrations (version) VALUES ('174');

INSERT INTO schema_migrations (version) VALUES ('175');

INSERT INTO schema_migrations (version) VALUES ('176');

INSERT INTO schema_migrations (version) VALUES ('177');

INSERT INTO schema_migrations (version) VALUES ('178');

INSERT INTO schema_migrations (version) VALUES ('179');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('180');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20081023162920');

INSERT INTO schema_migrations (version) VALUES ('20081023200331');

INSERT INTO schema_migrations (version) VALUES ('20081125201327');

INSERT INTO schema_migrations (version) VALUES ('20091211181230');

INSERT INTO schema_migrations (version) VALUES ('20091219152836');

INSERT INTO schema_migrations (version) VALUES ('20091228165906');

INSERT INTO schema_migrations (version) VALUES ('20100107171648');

INSERT INTO schema_migrations (version) VALUES ('20100114141548');

INSERT INTO schema_migrations (version) VALUES ('20100114154844');

INSERT INTO schema_migrations (version) VALUES ('20100120193442');

INSERT INTO schema_migrations (version) VALUES ('20100125215237');

INSERT INTO schema_migrations (version) VALUES ('20100128160556');

INSERT INTO schema_migrations (version) VALUES ('20100129194540');

INSERT INTO schema_migrations (version) VALUES ('20100209004341');

INSERT INTO schema_migrations (version) VALUES ('20100209044020');

INSERT INTO schema_migrations (version) VALUES ('20100209154702');

INSERT INTO schema_migrations (version) VALUES ('20100210132657');

INSERT INTO schema_migrations (version) VALUES ('20100211204243');

INSERT INTO schema_migrations (version) VALUES ('20100214200233');

INSERT INTO schema_migrations (version) VALUES ('20100219003106');

INSERT INTO schema_migrations (version) VALUES ('20100219004755');

INSERT INTO schema_migrations (version) VALUES ('20100302013305');

INSERT INTO schema_migrations (version) VALUES ('20100302045248');

INSERT INTO schema_migrations (version) VALUES ('20100404000529');

INSERT INTO schema_migrations (version) VALUES ('20100512175903');

INSERT INTO schema_migrations (version) VALUES ('20100513180558');

INSERT INTO schema_migrations (version) VALUES ('20100603154513');

INSERT INTO schema_migrations (version) VALUES ('20100607155549');

INSERT INTO schema_migrations (version) VALUES ('20100624184736');

INSERT INTO schema_migrations (version) VALUES ('20100628192154');

INSERT INTO schema_migrations (version) VALUES ('20100630042925');

INSERT INTO schema_migrations (version) VALUES ('20100706181119');

INSERT INTO schema_migrations (version) VALUES ('20100707011955');

INSERT INTO schema_migrations (version) VALUES ('20100707012048');

INSERT INTO schema_migrations (version) VALUES ('20100708013548');

INSERT INTO schema_migrations (version) VALUES ('20100708013617');

INSERT INTO schema_migrations (version) VALUES ('20100708032653');

INSERT INTO schema_migrations (version) VALUES ('20100715180454');

INSERT INTO schema_migrations (version) VALUES ('20100716141719');

INSERT INTO schema_migrations (version) VALUES ('20100716144408');

INSERT INTO schema_migrations (version) VALUES ('20100716190054');

INSERT INTO schema_migrations (version) VALUES ('20100805202342');

INSERT INTO schema_migrations (version) VALUES ('20100812144253');

INSERT INTO schema_migrations (version) VALUES ('20100812175727');

INSERT INTO schema_migrations (version) VALUES ('20100812184800');

INSERT INTO schema_migrations (version) VALUES ('20100813150554');

INSERT INTO schema_migrations (version) VALUES ('20100816023643');

INSERT INTO schema_migrations (version) VALUES ('20100816140646');

INSERT INTO schema_migrations (version) VALUES ('20100816142254');

INSERT INTO schema_migrations (version) VALUES ('20100816161920');

INSERT INTO schema_migrations (version) VALUES ('20100816161949');

INSERT INTO schema_migrations (version) VALUES ('20100816173025');

INSERT INTO schema_migrations (version) VALUES ('20100816190118');

INSERT INTO schema_migrations (version) VALUES ('20100816195510');

INSERT INTO schema_migrations (version) VALUES ('20100817164117');

INSERT INTO schema_migrations (version) VALUES ('20100817164204');

INSERT INTO schema_migrations (version) VALUES ('20100818015210');

INSERT INTO schema_migrations (version) VALUES ('20100819212753');

INSERT INTO schema_migrations (version) VALUES ('20100823140904');

INSERT INTO schema_migrations (version) VALUES ('20100825065802');

INSERT INTO schema_migrations (version) VALUES ('20100825073929');

INSERT INTO schema_migrations (version) VALUES ('20100827183806');

INSERT INTO schema_migrations (version) VALUES ('20100831164853');

INSERT INTO schema_migrations (version) VALUES ('20100901144150');

INSERT INTO schema_migrations (version) VALUES ('20100902194905');

INSERT INTO schema_migrations (version) VALUES ('20100906162449');

INSERT INTO schema_migrations (version) VALUES ('20100909163315');

INSERT INTO schema_migrations (version) VALUES ('20100909221737');

INSERT INTO schema_migrations (version) VALUES ('20100913154619');

INSERT INTO schema_migrations (version) VALUES ('20100919134728');

INSERT INTO schema_migrations (version) VALUES ('20100919182919');

INSERT INTO schema_migrations (version) VALUES ('20100920161617');

INSERT INTO schema_migrations (version) VALUES ('20100923050109');

INSERT INTO schema_migrations (version) VALUES ('20101004172601');

INSERT INTO schema_migrations (version) VALUES ('20101004174508');

INSERT INTO schema_migrations (version) VALUES ('20101008182416');

INSERT INTO schema_migrations (version) VALUES ('20101011133919');

INSERT INTO schema_migrations (version) VALUES ('20101011163404');

INSERT INTO schema_migrations (version) VALUES ('20101012131931');

INSERT INTO schema_migrations (version) VALUES ('20101012132624');

INSERT INTO schema_migrations (version) VALUES ('20101012150519');

INSERT INTO schema_migrations (version) VALUES ('20101014203047');

INSERT INTO schema_migrations (version) VALUES ('20101015145442');

INSERT INTO schema_migrations (version) VALUES ('20101016175652');

INSERT INTO schema_migrations (version) VALUES ('20101019001036');

INSERT INTO schema_migrations (version) VALUES ('20101019201248');

INSERT INTO schema_migrations (version) VALUES ('20101020195920');

INSERT INTO schema_migrations (version) VALUES ('20101021130331');

INSERT INTO schema_migrations (version) VALUES ('20101022205210');

INSERT INTO schema_migrations (version) VALUES ('20101029173730');

INSERT INTO schema_migrations (version) VALUES ('20101031193907');

INSERT INTO schema_migrations (version) VALUES ('20101104194010');

INSERT INTO schema_migrations (version) VALUES ('20101111203113');

INSERT INTO schema_migrations (version) VALUES ('20101119200445');

INSERT INTO schema_migrations (version) VALUES ('20101123130420');

INSERT INTO schema_migrations (version) VALUES ('20101201143104');

INSERT INTO schema_migrations (version) VALUES ('20101206001456');

INSERT INTO schema_migrations (version) VALUES ('20101207133547');

INSERT INTO schema_migrations (version) VALUES ('20101207203409');

INSERT INTO schema_migrations (version) VALUES ('20101212042403');

INSERT INTO schema_migrations (version) VALUES ('20101212050432');

INSERT INTO schema_migrations (version) VALUES ('20101212145611');

INSERT INTO schema_migrations (version) VALUES ('20101212170436');

INSERT INTO schema_migrations (version) VALUES ('20101215153816');

INSERT INTO schema_migrations (version) VALUES ('20101215155515');

INSERT INTO schema_migrations (version) VALUES ('20101219002033');

INSERT INTO schema_migrations (version) VALUES ('20101219002322');

INSERT INTO schema_migrations (version) VALUES ('20101221171037');

INSERT INTO schema_migrations (version) VALUES ('20101222012646');

INSERT INTO schema_migrations (version) VALUES ('20110108235747');

INSERT INTO schema_migrations (version) VALUES ('20110111041701');

INSERT INTO schema_migrations (version) VALUES ('20110111213242');

INSERT INTO schema_migrations (version) VALUES ('20110112035320');

INSERT INTO schema_migrations (version) VALUES ('20110112193620');

INSERT INTO schema_migrations (version) VALUES ('20110112195341');

INSERT INTO schema_migrations (version) VALUES ('20110427165631');

INSERT INTO schema_migrations (version) VALUES ('20110427165707');

INSERT INTO schema_migrations (version) VALUES ('20110430154757');

INSERT INTO schema_migrations (version) VALUES ('20110507180127');

INSERT INTO schema_migrations (version) VALUES ('20110507192037');

INSERT INTO schema_migrations (version) VALUES ('20110507192038');

INSERT INTO schema_migrations (version) VALUES ('20110509120742');

INSERT INTO schema_migrations (version) VALUES ('20110509154633');

INSERT INTO schema_migrations (version) VALUES ('20110509154634');

INSERT INTO schema_migrations (version) VALUES ('20110509154635');

INSERT INTO schema_migrations (version) VALUES ('20110509154636');

INSERT INTO schema_migrations (version) VALUES ('20110509154637');

INSERT INTO schema_migrations (version) VALUES ('20110509154638');

INSERT INTO schema_migrations (version) VALUES ('20110509154639');

INSERT INTO schema_migrations (version) VALUES ('20110509154640');

INSERT INTO schema_migrations (version) VALUES ('20110509154641');

INSERT INTO schema_migrations (version) VALUES ('20110509154642');

INSERT INTO schema_migrations (version) VALUES ('20110509154643');

INSERT INTO schema_migrations (version) VALUES ('20110509154644');

INSERT INTO schema_migrations (version) VALUES ('20110509154645');

INSERT INTO schema_migrations (version) VALUES ('20110509154646');

INSERT INTO schema_migrations (version) VALUES ('20110509154647');

INSERT INTO schema_migrations (version) VALUES ('20110509154648');

INSERT INTO schema_migrations (version) VALUES ('20110509154649');

INSERT INTO schema_migrations (version) VALUES ('20110509154650');

INSERT INTO schema_migrations (version) VALUES ('20110509154651');

INSERT INTO schema_migrations (version) VALUES ('20110509154848');

INSERT INTO schema_migrations (version) VALUES ('20110511192122');

INSERT INTO schema_migrations (version) VALUES ('20110511193318');

INSERT INTO schema_migrations (version) VALUES ('20110511200101');

INSERT INTO schema_migrations (version) VALUES ('20110511201652');

INSERT INTO schema_migrations (version) VALUES ('20110512152608');

INSERT INTO schema_migrations (version) VALUES ('20110512152638');

INSERT INTO schema_migrations (version) VALUES ('20110512210505');

INSERT INTO schema_migrations (version) VALUES ('20110513135021');

INSERT INTO schema_migrations (version) VALUES ('20110513173629');

INSERT INTO schema_migrations (version) VALUES ('20110514173802');

INSERT INTO schema_migrations (version) VALUES ('20110514174801');

INSERT INTO schema_migrations (version) VALUES ('20110514191919');

INSERT INTO schema_migrations (version) VALUES ('20110514200758');

INSERT INTO schema_migrations (version) VALUES ('20110514203517');

INSERT INTO schema_migrations (version) VALUES ('20110514205037');

INSERT INTO schema_migrations (version) VALUES ('20110514205934');

INSERT INTO schema_migrations (version) VALUES ('20110515142750');

INSERT INTO schema_migrations (version) VALUES ('20110517124354');

INSERT INTO schema_migrations (version) VALUES ('20110517191554');

INSERT INTO schema_migrations (version) VALUES ('20110519175216');

INSERT INTO schema_migrations (version) VALUES ('20110519175626');

INSERT INTO schema_migrations (version) VALUES ('20110519180010');

INSERT INTO schema_migrations (version) VALUES ('20110523171721');

INSERT INTO schema_migrations (version) VALUES ('20110526125711');

INSERT INTO schema_migrations (version) VALUES ('20110601194241');

INSERT INTO schema_migrations (version) VALUES ('20110606185355');

INSERT INTO schema_migrations (version) VALUES ('20110607133333');

INSERT INTO schema_migrations (version) VALUES ('20110614231828');

INSERT INTO schema_migrations (version) VALUES ('20110615001945');

INSERT INTO schema_migrations (version) VALUES ('20110615010025');

INSERT INTO schema_migrations (version) VALUES ('20110615163726');

INSERT INTO schema_migrations (version) VALUES ('20110615165726');

INSERT INTO schema_migrations (version) VALUES ('20110615191857');

INSERT INTO schema_migrations (version) VALUES ('20110615200849');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('70');

INSERT INTO schema_migrations (version) VALUES ('71');

INSERT INTO schema_migrations (version) VALUES ('72');

INSERT INTO schema_migrations (version) VALUES ('73');

INSERT INTO schema_migrations (version) VALUES ('74');

INSERT INTO schema_migrations (version) VALUES ('75');

INSERT INTO schema_migrations (version) VALUES ('76');

INSERT INTO schema_migrations (version) VALUES ('77');

INSERT INTO schema_migrations (version) VALUES ('78');

INSERT INTO schema_migrations (version) VALUES ('79');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('80');

INSERT INTO schema_migrations (version) VALUES ('81');

INSERT INTO schema_migrations (version) VALUES ('82');

INSERT INTO schema_migrations (version) VALUES ('83');

INSERT INTO schema_migrations (version) VALUES ('84');

INSERT INTO schema_migrations (version) VALUES ('85');

INSERT INTO schema_migrations (version) VALUES ('86');

INSERT INTO schema_migrations (version) VALUES ('87');

INSERT INTO schema_migrations (version) VALUES ('88');

INSERT INTO schema_migrations (version) VALUES ('89');

INSERT INTO schema_migrations (version) VALUES ('9');

INSERT INTO schema_migrations (version) VALUES ('90');

INSERT INTO schema_migrations (version) VALUES ('91');

INSERT INTO schema_migrations (version) VALUES ('92');

INSERT INTO schema_migrations (version) VALUES ('93');

INSERT INTO schema_migrations (version) VALUES ('94');

INSERT INTO schema_migrations (version) VALUES ('95');

INSERT INTO schema_migrations (version) VALUES ('96');

INSERT INTO schema_migrations (version) VALUES ('97');

INSERT INTO schema_migrations (version) VALUES ('98');

INSERT INTO schema_migrations (version) VALUES ('99');