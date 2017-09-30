-- MySQL dump 10.13  Distrib 5.7.19, for macos10.12 (x86_64)
--
-- Host: localhost    Database: missionhub
-- ------------------------------------------------------
-- Server version	5.7.19

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accepted_challenges`
--

DROP TABLE IF EXISTS `accepted_challenges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accepted_challenges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `accepted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `challenge_suggestion_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `organization_id` int(11) DEFAULT NULL,
  `notified_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_accepted_challenges_on_owner_id` (`owner_id`),
  KEY `index_accepted_challenges_on_receiver_id` (`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `access_grants`
--

DROP TABLE IF EXISTS `access_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_grants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `identity` int(11) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT '',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `granted_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `revoked` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_access_grants_on_code` (`code`),
  KEY `index_access_grants_on_client_id` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `access_tokens`
--

DROP TABLE IF EXISTS `access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `identity` int(11) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT '',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `active_admin_comments`
--

DROP TABLE IF EXISTS `active_admin_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `active_admin_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_id` int(11) NOT NULL,
  `resource_type` varchar(255) NOT NULL,
  `author_id` int(11) DEFAULT NULL,
  `author_type` varchar(255) DEFAULT NULL,
  `body` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `namespace` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_notes_on_resource_type_and_resource_id` (`resource_type`,`resource_id`),
  KEY `index_active_admin_comments_on_namespace` (`namespace`),
  KEY `index_active_admin_comments_on_author_type_and_author_id` (`author_type`,`author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `addresses` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `address3` varchar(55) DEFAULT NULL,
  `address4` varchar(55) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `zip` varchar(15) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  `address_type` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `person_id` int(10) DEFAULT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `dorm` varchar(255) DEFAULT NULL,
  `room` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_person_addressType` (`address_type`,`person_id`),
  KEY `fk_PersonID` (`person_id`),
  KEY `index_ministry_newAddress_on_addressType` (`address_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `answer_sheets`
--

DROP TABLE IF EXISTS `answer_sheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `answer_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `completed_at` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `survey_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id_survey_id` (`person_id`,`survey_id`),
  KEY `index_answer_sheets_on_survey_id` (`survey_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `answers`
--

DROP TABLE IF EXISTS `answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `answer_sheet_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `value` text,
  `short_value` text,
  `auto_notify_sent` tinyint(1) DEFAULT '0',
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ma_answers_on_answer_sheet_id` (`answer_sheet_id`),
  KEY `index_ma_answers_on_question_id` (`question_id`),
  CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `elements` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `api_logs`
--

DROP TABLE IF EXISTS `api_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `platform` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `identity` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `error` text,
  `url` text,
  `access_token` varchar(255) DEFAULT NULL,
  `remote_ip` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `platform_release` varchar(255) DEFAULT NULL,
  `platform_product` varchar(255) DEFAULT NULL,
  `app` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_requests`
--

DROP TABLE IF EXISTS `auth_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `client_id` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT '',
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `authentications`
--

DROP TABLE IF EXISTS `authentications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `authentications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `token` text,
  `mobile_token` text,
  `invalidated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid_provider` (`uid`,`provider`),
  KEY `user_id` (`user_id`),
  KEY `provider_token` (`provider`),
  CONSTRAINT `authentications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bulk_message_recipients`
--

DROP TABLE IF EXISTS `bulk_message_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bulk_message_recipients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bulk_message_id` int(11) DEFAULT NULL,
  `recipient_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `report` text COLLATE utf8_unicode_ci,
  `service_sid` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bulk_messages`
--

DROP TABLE IF EXISTS `bulk_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bulk_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `send_via` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `challenge_suggestions`
--

DROP TABLE IF EXISTS `challenge_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `challenge_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `challenge_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `notification_message` text COLLATE utf8_unicode_ci,
  `notification_delay` int(11) DEFAULT NULL,
  `pathway_stage_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `self_step` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chart_organizations`
--

DROP TABLE IF EXISTS `chart_organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chart_organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chart_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `snapshot_display` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `trend_display` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_chart_organizations_on_chart_id_and_organization_id` (`chart_id`,`organization_id`),
  KEY `index_chart_organizations_on_chart_id` (`chart_id`),
  KEY `index_chart_organizations_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `charts`
--

DROP TABLE IF EXISTS `charts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `charts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `chart_type` varchar(255) DEFAULT NULL,
  `snapshot_all_movements` tinyint(1) DEFAULT '1',
  `snapshot_evang_range` int(11) DEFAULT '6',
  `snapshot_laborers_range` int(11) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `goal_organization_id` int(11) DEFAULT NULL,
  `goal_criteria` varchar(255) DEFAULT NULL,
  `trend_all_movements` tinyint(1) DEFAULT '1',
  `trend_start_date` date DEFAULT NULL,
  `trend_end_date` date DEFAULT NULL,
  `trend_field_1` varchar(255) DEFAULT NULL,
  `trend_field_2` varchar(255) DEFAULT NULL,
  `trend_field_3` varchar(255) DEFAULT NULL,
  `trend_field_4` varchar(255) DEFAULT NULL,
  `trend_compare_year_ago` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_charts_on_person_id_and_chart_type` (`person_id`,`chart_type`),
  KEY `index_charts_on_person_id` (`person_id`),
  KEY `index_charts_on_chart_type` (`chart_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `secret` varchar(255) DEFAULT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `redirect_uri` varchar(255) DEFAULT NULL,
  `scope` varchar(255) DEFAULT '',
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `revoked` datetime DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_clients_on_code` (`code`),
  UNIQUE KEY `index_clients_on_display_name` (`display_name`),
  UNIQUE KEY `index_clients_on_link` (`link`),
  UNIQUE KEY `secret` (`secret`),
  KEY `index_clients_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_assignments`
--

DROP TABLE IF EXISTS `contact_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assigned_to_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `assigned_by_id` int(11) DEFAULT NULL,
  `notified` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `pathway_stage_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contact_assignments_on_assigned_to_id_and_organization_id` (`assigned_to_id`,`organization_id`),
  KEY `index_contact_assignments_on_organization_id` (`organization_id`),
  KEY `index_contact_assignments_on_person_id` (`person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `cru_statuses`
--

DROP TABLE IF EXISTS `cru_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cru_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `i18n` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_element_labels`
--

DROP TABLE IF EXISTS `custom_element_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_element_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `survey_id` int(11) DEFAULT NULL,
  `question_id` int(11) DEFAULT NULL,
  `label` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dashboard_posts`
--

DROP TABLE IF EXISTS `dashboard_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dashboard_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT '',
  `context` text,
  `video` varchar(255) DEFAULT '',
  `visible` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `education_histories`
--

DROP TABLE IF EXISTS `education_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `education_histories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `concentration_id1` varchar(255) DEFAULT NULL,
  `concentration_name1` varchar(255) DEFAULT NULL,
  `concentration_id2` varchar(255) DEFAULT NULL,
  `concentration_name2` varchar(255) DEFAULT NULL,
  `concentration_id3` varchar(255) DEFAULT NULL,
  `concentration_name3` varchar(255) DEFAULT NULL,
  `year_id` varchar(255) DEFAULT NULL,
  `year_name` varchar(255) DEFAULT NULL,
  `degree_id` varchar(255) DEFAULT NULL,
  `degree_name` varchar(255) DEFAULT NULL,
  `school_id` varchar(255) DEFAULT NULL,
  `school_name` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `school_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_education_histories_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `elements`
--

DROP TABLE IF EXISTS `elements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `kind` varchar(40) NOT NULL DEFAULT '',
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
  `web_only` tinyint(1) DEFAULT '0',
  `trigger_words` varchar(255) DEFAULT NULL,
  `notify_via` varchar(255) DEFAULT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT '0',
  `crs_question_id` int(11) DEFAULT NULL,
  `copy_from_element_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ma_elements_on_slug` (`slug`),
  KEY `index_ma_elements_on_question_sheet_id_and_position_and_page_id` (`position`),
  KEY `index_ma_elements_on_conditional_id` (`conditional_id`),
  KEY `index_ma_elements_on_question_grid_id` (`question_grid_id`),
  KEY `index_elements_on_crs_question_id` (`crs_question_id`),
  KEY `index_elements_on_kind` (`kind`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_addresses`
--

DROP TABLE IF EXISTS `email_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `person_id` (`person_id`),
  KEY `email` (`email`),
  CONSTRAINT `email_addresses_ibfk_1` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1014 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `email_responses`
--

DROP TABLE IF EXISTS `email_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_responses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `extra_info` text,
  `response_type` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `exports`
--

DROP TABLE IF EXISTS `exports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `options` text,
  `status` varchar(255) DEFAULT 'pending',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_exports_on_person_id` (`person_id`),
  KEY `index_exports_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `followup_comments`
--

DROP TABLE IF EXISTS `followup_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `followup_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `commenter_id` int(11) DEFAULT NULL,
  `comment` text,
  `status` varchar(255) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comment_organization_id_contact_id` (`organization_id`,`contact_id`),
  KEY `index_followup_comments_on_commenter_id` (`commenter_id`),
  KEY `index_followup_comments_on_deleted_at_and_contact_id` (`deleted_at`,`contact_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `friends_deprecated`
--

DROP TABLE IF EXISTS `friends_deprecated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `friends_deprecated` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_uid` (`person_id`,`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_labelings`
--

DROP TABLE IF EXISTS `group_labelings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_labelings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `group_label_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mh_group_labelings_on_group_id_and_group_label_id` (`group_id`,`group_label_id`),
  KEY `index_mh_group_labelings_on_group_label_id` (`group_label_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_labels`
--

DROP TABLE IF EXISTS `group_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `ancestry` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `group_labelings_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_mh_group_labels_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_memberships`
--

DROP TABLE IF EXISTS `group_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'member',
  `requested` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_group_memberships_on_group_id` (`group_id`),
  KEY `index_group_memberships_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `location` text,
  `meets` varchar(255) DEFAULT NULL,
  `meeting_day` int(11) DEFAULT NULL,
  `start_time` int(11) DEFAULT NULL,
  `end_time` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `list_publicly` tinyint(1) DEFAULT '1',
  `approve_join_requests` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_groups_on_name` (`name`),
  KEY `index_groups_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `imports`
--

DROP TABLE IF EXISTS `imports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `imports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `survey_ids` text,
  `upload_file_name` varchar(255) DEFAULT NULL,
  `upload_content_type` varchar(255) DEFAULT NULL,
  `upload_file_size` int(11) DEFAULT NULL,
  `upload_updated_at` datetime DEFAULT NULL,
  `headers` text,
  `header_mappings` text,
  `preview` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_org` (`user_id`,`organization_id`),
  KEY `index_mh_imports_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interaction_initiators`
--

DROP TABLE IF EXISTS `interaction_initiators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interaction_initiators` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `interaction_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_interaction_initiators_on_interaction_id` (`interaction_id`),
  KEY `index_interaction_initiators_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interaction_reports`
--

DROP TABLE IF EXISTS `interaction_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interaction_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organization_ids` text COLLATE utf8_unicode_ci,
  `report_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'details',
  `start_date` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `end_date` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `interaction_type_ids` text COLLATE utf8_unicode_ci,
  `enable_filters` tinyint(1) DEFAULT '0',
  `filters` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_interaction_reports_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interaction_types`
--

DROP TABLE IF EXISTS `interaction_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interaction_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `i18n` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_interaction_types_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interactions`
--

DROP TABLE IF EXISTS `interactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `interaction_type_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `updated_by_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `comment` text CHARACTER SET utf8,
  `privacy_setting` varchar(255) DEFAULT NULL,
  `timestamp` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_interactions_on_created_at` (`created_at`),
  KEY `index_interactions_on_receiver_id` (`receiver_id`),
  KEY `index_interactions_on_organization_id` (`organization_id`),
  KEY `index_interactions_ids` (`interaction_type_id`,`organization_id`,`deleted_at`),
  KEY `index_interactions_on_created_by_id` (`created_by_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interests`
--

DROP TABLE IF EXISTS `interests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `interest_id` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `interest_created_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `labels`
--

DROP TABLE IF EXISTS `labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `i18n` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_labels_on_organization_id` (`organization_id`),
  KEY `index_labels_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `legacy_bulk_messages`
--

DROP TABLE IF EXISTS `legacy_bulk_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `legacy_bulk_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `results` longtext,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_legacy_bulk_messages_on_person_id` (`person_id`),
  KEY `index_legacy_bulk_messages_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `long_codes`
--

DROP TABLE IF EXISTS `long_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `long_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT NULL,
  `messages_sent` int(11) DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `merge_audits`
--

DROP TABLE IF EXISTS `merge_audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bulk_message_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `from` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `reply_to` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text CHARACTER SET utf8,
  `sent_via` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sent` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_messages_on_bulk_message_id` (`bulk_message_id`),
  KEY `index_messages_on_to_sent_created_at` (`to`,`sent`,`created_at`),
  KEY `index_messages_on_reply_to_sent_via` (`reply_to`,`sent_via`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `movement_indicator_suggestions`
--

DROP TABLE IF EXISTS `movement_indicator_suggestions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `movement_indicator_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `label_id` int(11) DEFAULT NULL,
  `accepted` tinyint(1) DEFAULT NULL,
  `reason` varchar(1000) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `person_organization` (`organization_id`,`person_id`),
  KEY `person_organization_label` (`organization_id`,`person_id`,`label_id`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `new_people`
--

DROP TABLE IF EXISTS `new_people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `new_people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `notified` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_access_grants`
--

DROP TABLE IF EXISTS `oauth_access_grants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_grants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_owner_id` int(11) NOT NULL,
  `application_id` int(11) NOT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `expires_in` int(11) NOT NULL,
  `redirect_uri` text COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `scopes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_access_grants_on_token` (`token`),
  KEY `fk_rails_b4b53e07b8` (`application_id`),
  CONSTRAINT `fk_rails_b4b53e07b8` FOREIGN KEY (`application_id`) REFERENCES `oauth_applications` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_access_tokens`
--

DROP TABLE IF EXISTS `oauth_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_access_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resource_owner_id` int(11) DEFAULT NULL,
  `application_id` int(11) DEFAULT NULL,
  `token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `refresh_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expires_in` int(11) DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `scopes` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `previous_refresh_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_access_tokens_on_token` (`token`),
  UNIQUE KEY `index_oauth_access_tokens_on_refresh_token` (`refresh_token`),
  KEY `index_oauth_access_tokens_on_resource_owner_id` (`resource_owner_id`),
  KEY `fk_rails_732cb83ab7` (`application_id`),
  CONSTRAINT `fk_rails_732cb83ab7` FOREIGN KEY (`application_id`) REFERENCES `oauth_applications` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oauth_applications`
--

DROP TABLE IF EXISTS `oauth_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oauth_applications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `uid` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `secret` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `redirect_uri` text COLLATE utf8_unicode_ci NOT NULL,
  `scopes` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_oauth_applications_on_uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization_memberships`
--

DROP TABLE IF EXISTS `organization_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organization_memberships_on_organization_id_and_person_id` (`organization_id`,`person_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `organization_memberships_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organization_memberships_deprecated`
--

DROP TABLE IF EXISTS `organization_memberships_deprecated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization_memberships_deprecated` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `primary` tinyint(1) DEFAULT '0',
  `validated` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organization_memberships_on_organization_id_and_person_id` (`organization_id`,`person_id`),
  KEY `person_id` (`person_id`),
  CONSTRAINT `organization_memberships_deprecated_ibfk_2` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizational_goals`
--

DROP TABLE IF EXISTS `organizational_goals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizational_goals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `criteria` varchar(255) DEFAULT NULL,
  `start_value` int(11) DEFAULT NULL,
  `end_value` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_organizational_goals_on_organization_id` (`organization_id`),
  KEY `index_organizational_goals_on_criteria` (`criteria`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizational_labels`
--

DROP TABLE IF EXISTS `organizational_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizational_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `label_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `added_by_id` int(11) DEFAULT NULL,
  `removed_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_organizational_labels_on_person_id` (`person_id`),
  KEY `index_organizational_labels_on_label_id` (`label_id`),
  KEY `index_organizational_labels_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizational_permissions`
--

DROP TABLE IF EXISTS `organizational_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizational_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `permission_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `cru_status_id` int(11) DEFAULT NULL,
  `followup_status` varchar(255) DEFAULT NULL,
  `added_by_id` int(11) DEFAULT NULL,
  `archive_date` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `person_role_org` (`person_id`,`organization_id`,`permission_id`),
  KEY `role_org_status` (`organization_id`,`permission_id`,`followup_status`),
  KEY `index_organizational_permissions_on_person_id` (`person_id`),
  KEY `index_organizational_permissions_on_permission_id` (`permission_id`),
  KEY `index_organizational_permissions_on_organization_id` (`organization_id`),
  KEY `index_organizational_permissions_ids` (`permission_id`,`organization_id`,`archive_date`,`deleted_at`),
  CONSTRAINT `organizational_permissions_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1019 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizations`
--

DROP TABLE IF EXISTS `organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `show_sub_orgs` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `settings` text,
  `conference_id` int(11) DEFAULT NULL,
  `last_indicator_suggestion_at` datetime DEFAULT NULL,
  `last_push_to_infobase` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_organizations_on_importable_type_and_importable_id` (`importable_type`,`importable_id`),
  KEY `index_organizations_on_ancestry` (`ancestry`),
  KEY `index_organizations_on_name` (`name`),
  KEY `index_organizations_on_conference_id` (`conference_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pathway_progression_audits`
--

DROP TABLE IF EXISTS `pathway_progression_audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pathway_progression_audits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_assignment_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `assigned_to_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `old_stage_id` int(11) DEFAULT NULL,
  `new_stage_id` int(11) DEFAULT NULL,
  `difference` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pathway_stages`
--

DROP TABLE IF EXISTS `pathway_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pathway_stages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `name_i18n` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description_i18n` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `accountNo` varchar(11) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `student_status` varchar(255) DEFAULT NULL,
  `campus` varchar(128) DEFAULT NULL,
  `year_in_school` varchar(50) DEFAULT NULL,
  `major` varchar(70) DEFAULT NULL,
  `minor` varchar(70) DEFAULT NULL,
  `greek_affiliation` varchar(50) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(10) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `date_became_christian` date DEFAULT NULL,
  `graduation_date` date DEFAULT NULL,
  `level_of_school` varchar(255) DEFAULT NULL,
  `staff_notes` varchar(255) DEFAULT NULL,
  `primary_campus_involvement_id` int(11) DEFAULT NULL,
  `mentor_id` int(11) DEFAULT NULL,
  `fb_uid` bigint(20) unsigned DEFAULT NULL,
  `date_attributes_updated` datetime DEFAULT NULL,
  `crs_profile_id` int(11) DEFAULT NULL,
  `sp_person_id` int(11) DEFAULT NULL,
  `si_person_id` int(11) DEFAULT NULL,
  `pr_person_id` int(11) DEFAULT NULL,
  `faculty` tinyint(1) NOT NULL DEFAULT '0',
  `is_staff` tinyint(1) NOT NULL DEFAULT '0',
  `infobase_person_id` int(11) DEFAULT NULL,
  `nationality` varchar(255) DEFAULT NULL,
  `avatar_file_name` varchar(255) DEFAULT NULL,
  `avatar_content_type` varchar(255) DEFAULT NULL,
  `avatar_file_size` int(11) DEFAULT NULL,
  `avatar_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lastname_ministry_Person` (`last_name`),
  KEY `fk_ssmUserId` (`user_id`),
  KEY `campus` (`campus`),
  KEY `index_ministry_person_on_fb_uid` (`fb_uid`),
  KEY `accountNo_ministry_Person` (`accountNo`),
  KEY `firstName_lastName` (`first_name`,`last_name`),
  KEY `index_people_on_crs_profile_id` (`crs_profile_id`),
  KEY `index_people_on_sp_person_id` (`sp_person_id`),
  KEY `index_people_on_si_person_id` (`si_person_id`),
  KEY `index_people_on_pr_person_id` (`pr_person_id`),
  KEY `index_people_on_infobase_person_id` (`infobase_person_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1016 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `i18n` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_permissions_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_photos`
--

DROP TABLE IF EXISTS `person_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_photos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_signatures`
--

DROP TABLE IF EXISTS `person_signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_signatures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_person_signatures_on_person_id` (`person_id`),
  KEY `index_person_signatures_on_organization_id` (`organization_id`),
  CONSTRAINT `fk_rails_6658944366` FOREIGN KEY (`person_id`) REFERENCES `people` (`id`),
  CONSTRAINT `fk_rails_b5d6e4f823` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_transfers`
--

DROP TABLE IF EXISTS `person_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_transfers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `old_organization_id` int(11) DEFAULT NULL,
  `new_organization_id` int(11) DEFAULT NULL,
  `copy` tinyint(1) DEFAULT '0',
  `notified` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `transferred_by_id` int(11) DEFAULT NULL,
  `skipped` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phone_numbers`
--

DROP TABLE IF EXISTS `phone_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phone_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT NULL,
  `extension` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `location` varchar(255) DEFAULT 'mobile',
  `primary` tinyint(1) DEFAULT '0',
  `not_mobile` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `txt_to_email` varchar(255) DEFAULT NULL,
  `carrier_id` int(11) DEFAULT NULL,
  `email_updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_phone_numbers_on_carrier_id` (`carrier_id`),
  KEY `index_phone_numbers_on_person_id_and_number` (`person_id`,`number`),
  KEY `index_phone_numbers_on_number` (`number`)
) ENGINE=InnoDB AUTO_INCREMENT=1014 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `profile_pictures`
--

DROP TABLE IF EXISTS `profile_pictures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `question_leaders`
--

DROP TABLE IF EXISTS `question_leaders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question_leaders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `element_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `question_rules`
--

DROP TABLE IF EXISTS `question_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question_rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `survey_element_id` int(11) DEFAULT NULL,
  `rule_id` int(11) DEFAULT NULL,
  `trigger_keywords` varchar(255) DEFAULT NULL,
  `extra_parameters` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `question_sheets`
--

DROP TABLE IF EXISTS `question_sheets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `question_sheets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(60) NOT NULL DEFAULT '',
  `archived` tinyint(1) DEFAULT '0',
  `questionnable_id` int(11) DEFAULT NULL,
  `questionnable_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `questionnable` (`questionnable_id`,`questionnable_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rails_admin_histories`
--

DROP TABLE IF EXISTS `rails_admin_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `received_sms`
--

DROP TABLE IF EXISTS `received_sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `received_sms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(255) DEFAULT NULL,
  `carrier` varchar(255) DEFAULT NULL,
  `shortcode` varchar(255) DEFAULT NULL,
  `message` text,
  `country` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sms_keyword_id` int(11) DEFAULT NULL,
  `sms_session_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip` varchar(255) DEFAULT NULL,
  `twilio_sid` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_received_sms_on_twilio_sid` (`twilio_sid`),
  KEY `person_id` (`person_id`),
  KEY `index_received_sms_on_city_and_state_and_zip_and_country` (`city`,`state`,`zip`,`country`)
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rejoicables`
--

DROP TABLE IF EXISTS `rejoicables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rejoicables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `created_by_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `followup_comment_id` int(11) DEFAULT NULL,
  `what` enum('spiritual_conversation','prayed_to_receive','gospel_presentation') DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rules`
--

DROP TABLE IF EXISTS `rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `action_method` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `limit_per_survey` int(11) DEFAULT '0',
  `rule_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `saved_contact_searches`
--

DROP TABLE IF EXISTS `saved_contact_searches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_contact_searches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `full_path` varchar(4000) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_saved_contact_searches_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `saved_visual_tools`
--

DROP TABLE IF EXISTS `saved_visual_tools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `saved_visual_tools` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `group` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `movement_ids` text,
  `more_info` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_saved_visual_tools_on_person_id` (`person_id`),
  KEY `index_saved_visual_tools_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `school_years`
--

DROP TABLE IF EXISTS `school_years`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `school_years` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `level` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sent_people`
--

DROP TABLE IF EXISTS `sent_people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sent_people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `transferred_by_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sent_sms`
--

DROP TABLE IF EXISTS `sent_sms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sent_sms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message_id` int(11) DEFAULT NULL,
  `message` text,
  `recipient` varchar(255) DEFAULT NULL,
  `reports` text,
  `moonshado_claimcheck` varchar(255) DEFAULT NULL,
  `sent_via` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT 'queued',
  `received_sms_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `twilio_sid` varchar(255) DEFAULT NULL,
  `twilio_uri` varchar(255) DEFAULT NULL,
  `separator` varchar(255) DEFAULT NULL,
  `question_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sent_sms_on_twilio_sid` (`twilio_sid`),
  KEY `index_sent_sms_on_message_id` (`message_id`),
  KEY `index_sent_sms_on_received_sms_id_id` (`received_sms_id`)
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `signatures`
--

DROP TABLE IF EXISTS `signatures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `signatures` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_signature_id` int(11) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_signatures_on_person_signature_id` (`person_signature_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_carriers`
--

DROP TABLE IF EXISTS `sms_carriers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `cloudvox_name` varchar(255) DEFAULT NULL,
  `data247_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_keywords`
--

DROP TABLE IF EXISTS `sms_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `initial_response` varchar(145) DEFAULT NULL,
  `post_survey_message_deprecated` text,
  `event_type` varchar(255) DEFAULT NULL,
  `gateway` varchar(255) NOT NULL DEFAULT 'twilio',
  `survey_id` int(11) DEFAULT NULL,
  `mpd` tinyint(1) NOT NULL DEFAULT '0',
  `mpd_phone_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `organization_id` (`organization_id`),
  KEY `index_sms_keywords_on_survey_id` (`survey_id`),
  CONSTRAINT `sms_keywords_ibfk_3` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  CONSTRAINT `sms_keywords_ibfk_4` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_sessions`
--

DROP TABLE IF EXISTS `sms_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(255) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `sms_keyword_id` int(11) DEFAULT NULL,
  `interactive` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ended` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `session` (`phone_number`,`updated_at`),
  KEY `index_sms_sessions_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sms_unsubscribes`
--

DROP TABLE IF EXISTS `sms_unsubscribes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_unsubscribes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(255) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription_choices`
--

DROP TABLE IF EXISTS `subscription_choices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_choices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` int(11) DEFAULT NULL,
  `subscription_sms_session_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscription_sms_sessions`
--

DROP TABLE IF EXISTS `subscription_sms_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscription_sms_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `interactive` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `ended` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `super_admins`
--

DROP TABLE IF EXISTS `super_admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `super_admins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `site` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_super_admins_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `suppressed_numbers`
--

DROP TABLE IF EXISTS `suppressed_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suppressed_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `number` varchar(255) DEFAULT NULL,
  `reason` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `survey_elements`
--

DROP TABLE IF EXISTS `survey_elements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `survey_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `survey_id` int(11) DEFAULT NULL,
  `element_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT '0',
  `archived` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `survey_id_element_id` (`survey_id`,`element_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `surveys`
--

DROP TABLE IF EXISTS `surveys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `surveys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL DEFAULT '',
  `organization_id` int(11) DEFAULT NULL,
  `copy_from_survey_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `post_survey_message` text,
  `terminology` varchar(255) DEFAULT 'Survey',
  `login_option` int(11) DEFAULT '0',
  `is_frozen` tinyint(1) DEFAULT NULL,
  `login_paragraph` text,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `logo_updated_at` datetime DEFAULT NULL,
  `css_file_file_name` varchar(255) DEFAULT NULL,
  `css_file_content_type` varchar(255) DEFAULT NULL,
  `css_file_file_size` int(11) DEFAULT NULL,
  `css_file_updated_at` datetime DEFAULT NULL,
  `css` text,
  `background_color` varchar(255) DEFAULT NULL,
  `text_color` varchar(255) DEFAULT NULL,
  `crs_registrant_type_id` int(11) DEFAULT NULL,
  `redirect_url` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mh_surveys_on_organization_id` (`organization_id`),
  KEY `index_surveys_on_crs_registrant_type_id` (`crs_registrant_type_id`),
  CONSTRAINT `surveys_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `username` varchar(200) NOT NULL,
  `password` varchar(80) DEFAULT NULL,
  `remember_token` varchar(255) DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `developer` tinyint(1) DEFAULT NULL,
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
  `settings` text,
  `timezone` varchar(255) DEFAULT NULL,
  `subscribed_to_updates` tinyint(1) DEFAULT NULL,
  `pathway_stage_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `CK_simplesecuritymanager_user_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `versions`
--

DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_type` varchar(255) NOT NULL,
  `item_id` int(11) NOT NULL,
  `event` varchar(255) NOT NULL,
  `whodunnit` varchar(255) DEFAULT NULL,
  `object` text CHARACTER SET utf8 COLLATE utf8_bin,
  `organization_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`),
  KEY `index_versions_on_person_id_and_created_at` (`person_id`,`created_at`),
  KEY `index_versions_on_organization_id_and_created_at` (`organization_id`,`created_at`),
  KEY `index_versions_on_item_id` (`item_id`),
  KEY `index_versions_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=1036 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-09-29 21:04:02
INSERT INTO schema_migrations (version) VALUES ('20101206001456');

INSERT INTO schema_migrations (version) VALUES ('20101212042403');

INSERT INTO schema_migrations (version) VALUES ('20101212050432');

INSERT INTO schema_migrations (version) VALUES ('20101212145610');

INSERT INTO schema_migrations (version) VALUES ('20101212145611');

INSERT INTO schema_migrations (version) VALUES ('20101212170436');

INSERT INTO schema_migrations (version) VALUES ('20101215155514');

INSERT INTO schema_migrations (version) VALUES ('20101215155515');

INSERT INTO schema_migrations (version) VALUES ('20101219002033');

INSERT INTO schema_migrations (version) VALUES ('20101219002322');

INSERT INTO schema_migrations (version) VALUES ('20101221171037');

INSERT INTO schema_migrations (version) VALUES ('20110108235747');

INSERT INTO schema_migrations (version) VALUES ('20110427165631');

INSERT INTO schema_migrations (version) VALUES ('20110427165707');

INSERT INTO schema_migrations (version) VALUES ('20110430154757');

INSERT INTO schema_migrations (version) VALUES ('20110507180127');

INSERT INTO schema_migrations (version) VALUES ('20110507192037');

INSERT INTO schema_migrations (version) VALUES ('20110507192038');

INSERT INTO schema_migrations (version) VALUES ('20110509120742');

INSERT INTO schema_migrations (version) VALUES ('20110509154633');

INSERT INTO schema_migrations (version) VALUES ('20110509154634');

INSERT INTO schema_migrations (version) VALUES ('20110509154636');

INSERT INTO schema_migrations (version) VALUES ('20110509154637');

INSERT INTO schema_migrations (version) VALUES ('20110509154638');

INSERT INTO schema_migrations (version) VALUES ('20110509154639');

INSERT INTO schema_migrations (version) VALUES ('20110509154642');

INSERT INTO schema_migrations (version) VALUES ('20110509154643');

INSERT INTO schema_migrations (version) VALUES ('20110509154644');

INSERT INTO schema_migrations (version) VALUES ('20110509154645');

INSERT INTO schema_migrations (version) VALUES ('20110509154646');

INSERT INTO schema_migrations (version) VALUES ('20110509154649');

INSERT INTO schema_migrations (version) VALUES ('20110509154650');

INSERT INTO schema_migrations (version) VALUES ('20110509154651');

INSERT INTO schema_migrations (version) VALUES ('20110509154848');

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

INSERT INTO schema_migrations (version) VALUES ('20110519175216');

INSERT INTO schema_migrations (version) VALUES ('20110519175626');

INSERT INTO schema_migrations (version) VALUES ('20110519180010');

INSERT INTO schema_migrations (version) VALUES ('20110523171721');

INSERT INTO schema_migrations (version) VALUES ('20110526125711');

INSERT INTO schema_migrations (version) VALUES ('20110601194241');

INSERT INTO schema_migrations (version) VALUES ('20110606185355');

INSERT INTO schema_migrations (version) VALUES ('20110607133333');

INSERT INTO schema_migrations (version) VALUES ('20110615001945');

INSERT INTO schema_migrations (version) VALUES ('20110615010025');

INSERT INTO schema_migrations (version) VALUES ('20110615163726');

INSERT INTO schema_migrations (version) VALUES ('20110615164726');

INSERT INTO schema_migrations (version) VALUES ('20110615165726');

INSERT INTO schema_migrations (version) VALUES ('20110615191857');

INSERT INTO schema_migrations (version) VALUES ('20110615200849');

INSERT INTO schema_migrations (version) VALUES ('20110627203939');

INSERT INTO schema_migrations (version) VALUES ('20110627204929');

INSERT INTO schema_migrations (version) VALUES ('20110628210730');

INSERT INTO schema_migrations (version) VALUES ('20110628230112');

INSERT INTO schema_migrations (version) VALUES ('20110629054522');

INSERT INTO schema_migrations (version) VALUES ('20110708031833');

INSERT INTO schema_migrations (version) VALUES ('20110708033332');

INSERT INTO schema_migrations (version) VALUES ('20110710014153');

INSERT INTO schema_migrations (version) VALUES ('20110710052424');

INSERT INTO schema_migrations (version) VALUES ('20110714125841');

INSERT INTO schema_migrations (version) VALUES ('20110715161200');

INSERT INTO schema_migrations (version) VALUES ('20110715170234');

INSERT INTO schema_migrations (version) VALUES ('20110720115151');

INSERT INTO schema_migrations (version) VALUES ('20110720165852');

INSERT INTO schema_migrations (version) VALUES ('20110720170450');

INSERT INTO schema_migrations (version) VALUES ('20110720174832');

INSERT INTO schema_migrations (version) VALUES ('20110721134014');

INSERT INTO schema_migrations (version) VALUES ('20110806180552');

INSERT INTO schema_migrations (version) VALUES ('20110806182402');

INSERT INTO schema_migrations (version) VALUES ('20110810182643');

INSERT INTO schema_migrations (version) VALUES ('20110818145930');

INSERT INTO schema_migrations (version) VALUES ('20110831011404');

INSERT INTO schema_migrations (version) VALUES ('20111010163721');

INSERT INTO schema_migrations (version) VALUES ('20111011102148');

INSERT INTO schema_migrations (version) VALUES ('20111011102149');

INSERT INTO schema_migrations (version) VALUES ('20111011140850');

INSERT INTO schema_migrations (version) VALUES ('20111011195158');

INSERT INTO schema_migrations (version) VALUES ('20111020171606');

INSERT INTO schema_migrations (version) VALUES ('20111020174602');

INSERT INTO schema_migrations (version) VALUES ('20111020183940');

INSERT INTO schema_migrations (version) VALUES ('20111020183941');

INSERT INTO schema_migrations (version) VALUES ('20111024182333');

INSERT INTO schema_migrations (version) VALUES ('20111024194753');

INSERT INTO schema_migrations (version) VALUES ('20111025181852');

INSERT INTO schema_migrations (version) VALUES ('20111025181954');

INSERT INTO schema_migrations (version) VALUES ('20111026223659');

INSERT INTO schema_migrations (version) VALUES ('20111026223927');

INSERT INTO schema_migrations (version) VALUES ('20111028144358');

INSERT INTO schema_migrations (version) VALUES ('20111028185228');

INSERT INTO schema_migrations (version) VALUES ('20111028194831');

INSERT INTO schema_migrations (version) VALUES ('20111109023238');

INSERT INTO schema_migrations (version) VALUES ('20111110195907');

INSERT INTO schema_migrations (version) VALUES ('20111114151916');

INSERT INTO schema_migrations (version) VALUES ('20111116164718');

INSERT INTO schema_migrations (version) VALUES ('20111121165021');

INSERT INTO schema_migrations (version) VALUES ('20111129201039');

INSERT INTO schema_migrations (version) VALUES ('20111129201040');

INSERT INTO schema_migrations (version) VALUES ('20111130140314');

INSERT INTO schema_migrations (version) VALUES ('20111206144944');

INSERT INTO schema_migrations (version) VALUES ('20111217155231');

INSERT INTO schema_migrations (version) VALUES ('20111222175718');

INSERT INTO schema_migrations (version) VALUES ('20120111194425');

INSERT INTO schema_migrations (version) VALUES ('20120118193956');

INSERT INTO schema_migrations (version) VALUES ('20120125122043');

INSERT INTO schema_migrations (version) VALUES ('20120125142748');

INSERT INTO schema_migrations (version) VALUES ('20120125154319');

INSERT INTO schema_migrations (version) VALUES ('20120125165234');

INSERT INTO schema_migrations (version) VALUES ('20120201201417');

INSERT INTO schema_migrations (version) VALUES ('20120203200420');

INSERT INTO schema_migrations (version) VALUES ('20120206202605');

INSERT INTO schema_migrations (version) VALUES ('20120307155057');

INSERT INTO schema_migrations (version) VALUES ('20120422020609');

INSERT INTO schema_migrations (version) VALUES ('20120517184505');

INSERT INTO schema_migrations (version) VALUES ('20120518131853');

INSERT INTO schema_migrations (version) VALUES ('20120601090219');

INSERT INTO schema_migrations (version) VALUES ('20120608153555');

INSERT INTO schema_migrations (version) VALUES ('20120608153742');

INSERT INTO schema_migrations (version) VALUES ('20120608165037');

INSERT INTO schema_migrations (version) VALUES ('20120608170021');

INSERT INTO schema_migrations (version) VALUES ('20120619135454');

INSERT INTO schema_migrations (version) VALUES ('20120711080607');

INSERT INTO schema_migrations (version) VALUES ('20120720162850');

INSERT INTO schema_migrations (version) VALUES ('20120724000933');

INSERT INTO schema_migrations (version) VALUES ('20120808201319');

INSERT INTO schema_migrations (version) VALUES ('20120814200612');

INSERT INTO schema_migrations (version) VALUES ('20120821154652');

INSERT INTO schema_migrations (version) VALUES ('20120905172032');

INSERT INTO schema_migrations (version) VALUES ('20121017144708');

INSERT INTO schema_migrations (version) VALUES ('20121018152313');

INSERT INTO schema_migrations (version) VALUES ('20121020162838');

INSERT INTO schema_migrations (version) VALUES ('20121020193612');

INSERT INTO schema_migrations (version) VALUES ('20121102181250');

INSERT INTO schema_migrations (version) VALUES ('20121103161704');

INSERT INTO schema_migrations (version) VALUES ('20121109101429');

INSERT INTO schema_migrations (version) VALUES ('20121128073103');

INSERT INTO schema_migrations (version) VALUES ('20121128143328');

INSERT INTO schema_migrations (version) VALUES ('20121205141609');

INSERT INTO schema_migrations (version) VALUES ('20121205205752');

INSERT INTO schema_migrations (version) VALUES ('20130102161031');

INSERT INTO schema_migrations (version) VALUES ('20130319163107');

INSERT INTO schema_migrations (version) VALUES ('20130325184808');

INSERT INTO schema_migrations (version) VALUES ('20130425064847');

INSERT INTO schema_migrations (version) VALUES ('20130502093320');

INSERT INTO schema_migrations (version) VALUES ('20130502093511');

INSERT INTO schema_migrations (version) VALUES ('20130502093556');

INSERT INTO schema_migrations (version) VALUES ('20130502141633');

INSERT INTO schema_migrations (version) VALUES ('20130502163825');

INSERT INTO schema_migrations (version) VALUES ('20130521153218');

INSERT INTO schema_migrations (version) VALUES ('20130521153531');

INSERT INTO schema_migrations (version) VALUES ('20130521155304');

INSERT INTO schema_migrations (version) VALUES ('20130524183956');

INSERT INTO schema_migrations (version) VALUES ('20130606053208');

INSERT INTO schema_migrations (version) VALUES ('20130607170230');

INSERT INTO schema_migrations (version) VALUES ('20130610215048');

INSERT INTO schema_migrations (version) VALUES ('20130611204940');

INSERT INTO schema_migrations (version) VALUES ('20130611214719');

INSERT INTO schema_migrations (version) VALUES ('20130617204613');

INSERT INTO schema_migrations (version) VALUES ('20130620084026');

INSERT INTO schema_migrations (version) VALUES ('20130620090540');

INSERT INTO schema_migrations (version) VALUES ('20130624112438');

INSERT INTO schema_migrations (version) VALUES ('20130626160951');

INSERT INTO schema_migrations (version) VALUES ('20130626170858');

INSERT INTO schema_migrations (version) VALUES ('20130628132340');

INSERT INTO schema_migrations (version) VALUES ('20130702161132');

INSERT INTO schema_migrations (version) VALUES ('20130703090751');

INSERT INTO schema_migrations (version) VALUES ('20130711183515');

INSERT INTO schema_migrations (version) VALUES ('20130712024551');

INSERT INTO schema_migrations (version) VALUES ('20130712094925');

INSERT INTO schema_migrations (version) VALUES ('20130801155007');

INSERT INTO schema_migrations (version) VALUES ('20130806154625');

INSERT INTO schema_migrations (version) VALUES ('20130828080029');

INSERT INTO schema_migrations (version) VALUES ('20130829040039');

INSERT INTO schema_migrations (version) VALUES ('20130905203304');

INSERT INTO schema_migrations (version) VALUES ('20130924190843');

INSERT INTO schema_migrations (version) VALUES ('20130930175051');

INSERT INTO schema_migrations (version) VALUES ('20131008115504');

INSERT INTO schema_migrations (version) VALUES ('20131010165952');

INSERT INTO schema_migrations (version) VALUES ('20131120102232');

INSERT INTO schema_migrations (version) VALUES ('20131125152750');

INSERT INTO schema_migrations (version) VALUES ('20131126065750');

INSERT INTO schema_migrations (version) VALUES ('20131206115655');

INSERT INTO schema_migrations (version) VALUES ('20131211000452');

INSERT INTO schema_migrations (version) VALUES ('20131223132938');

INSERT INTO schema_migrations (version) VALUES ('20140208154001');

INSERT INTO schema_migrations (version) VALUES ('20140228005834');

INSERT INTO schema_migrations (version) VALUES ('20140321060144');

INSERT INTO schema_migrations (version) VALUES ('20140502164454');

INSERT INTO schema_migrations (version) VALUES ('20140502164626');

INSERT INTO schema_migrations (version) VALUES ('20140502165943');

INSERT INTO schema_migrations (version) VALUES ('20140509032720');

INSERT INTO schema_migrations (version) VALUES ('20140526045529');

INSERT INTO schema_migrations (version) VALUES ('20140722171641');

INSERT INTO schema_migrations (version) VALUES ('20140807161927');

INSERT INTO schema_migrations (version) VALUES ('20140901083254');

INSERT INTO schema_migrations (version) VALUES ('20140901145245');

INSERT INTO schema_migrations (version) VALUES ('20140903175521');

INSERT INTO schema_migrations (version) VALUES ('20140903175542');

INSERT INTO schema_migrations (version) VALUES ('20140904081607');

INSERT INTO schema_migrations (version) VALUES ('20140910130707');

INSERT INTO schema_migrations (version) VALUES ('20140926052729');

INSERT INTO schema_migrations (version) VALUES ('20141028143450');

INSERT INTO schema_migrations (version) VALUES ('20141029164010');

INSERT INTO schema_migrations (version) VALUES ('20141029164136');

INSERT INTO schema_migrations (version) VALUES ('20141103073037');

INSERT INTO schema_migrations (version) VALUES ('20141114085748');

INSERT INTO schema_migrations (version) VALUES ('20141117172120');

INSERT INTO schema_migrations (version) VALUES ('20150112145321');

INSERT INTO schema_migrations (version) VALUES ('20150113062028');

INSERT INTO schema_migrations (version) VALUES ('20150113084545');

INSERT INTO schema_migrations (version) VALUES ('20150113143731');

INSERT INTO schema_migrations (version) VALUES ('20150210140121');

INSERT INTO schema_migrations (version) VALUES ('20150210162245');

INSERT INTO schema_migrations (version) VALUES ('20150218055518');

INSERT INTO schema_migrations (version) VALUES ('20150219040425');

INSERT INTO schema_migrations (version) VALUES ('20150317130749');

INSERT INTO schema_migrations (version) VALUES ('20150324195258');

INSERT INTO schema_migrations (version) VALUES ('20150331062244');

INSERT INTO schema_migrations (version) VALUES ('20150414024912');

INSERT INTO schema_migrations (version) VALUES ('20150422111055');

INSERT INTO schema_migrations (version) VALUES ('20150422164952');

INSERT INTO schema_migrations (version) VALUES ('20150428110230');

INSERT INTO schema_migrations (version) VALUES ('20150428112307');

INSERT INTO schema_migrations (version) VALUES ('20150430101424');

INSERT INTO schema_migrations (version) VALUES ('20150505104720');

INSERT INTO schema_migrations (version) VALUES ('20150601040052');

INSERT INTO schema_migrations (version) VALUES ('20150601193609');

INSERT INTO schema_migrations (version) VALUES ('20150702114523');

INSERT INTO schema_migrations (version) VALUES ('20150803190304');

INSERT INTO schema_migrations (version) VALUES ('20150811203455');

INSERT INTO schema_migrations (version) VALUES ('20150815141203');

INSERT INTO schema_migrations (version) VALUES ('20150820130316');

INSERT INTO schema_migrations (version) VALUES ('20150821084429');

INSERT INTO schema_migrations (version) VALUES ('20150824065104');

INSERT INTO schema_migrations (version) VALUES ('20150824135028');

INSERT INTO schema_migrations (version) VALUES ('20150825023940');

INSERT INTO schema_migrations (version) VALUES ('20150825080752');

INSERT INTO schema_migrations (version) VALUES ('20150827212754');

INSERT INTO schema_migrations (version) VALUES ('20150828031950');

INSERT INTO schema_migrations (version) VALUES ('20150901024149');

INSERT INTO schema_migrations (version) VALUES ('20150901124349');

INSERT INTO schema_migrations (version) VALUES ('20150902031005');

INSERT INTO schema_migrations (version) VALUES ('20150904043048');

INSERT INTO schema_migrations (version) VALUES ('20150904043110');

INSERT INTO schema_migrations (version) VALUES ('20150925143003');

INSERT INTO schema_migrations (version) VALUES ('20151009143553');

INSERT INTO schema_migrations (version) VALUES ('20151013235509');

INSERT INTO schema_migrations (version) VALUES ('20151014200129');

INSERT INTO schema_migrations (version) VALUES ('20160722224633');

INSERT INTO schema_migrations (version) VALUES ('20160810205649');

INSERT INTO schema_migrations (version) VALUES ('20160812161101');

INSERT INTO schema_migrations (version) VALUES ('20160812161138');

INSERT INTO schema_migrations (version) VALUES ('20160815165035');

INSERT INTO schema_migrations (version) VALUES ('20160815165046');

INSERT INTO schema_migrations (version) VALUES ('20160817180122');

INSERT INTO schema_migrations (version) VALUES ('20160817180226');

INSERT INTO schema_migrations (version) VALUES ('20160817180248');

INSERT INTO schema_migrations (version) VALUES ('20160817180310');

INSERT INTO schema_migrations (version) VALUES ('20160817180339');

INSERT INTO schema_migrations (version) VALUES ('20160817185155');

INSERT INTO schema_migrations (version) VALUES ('20160818124248');

INSERT INTO schema_migrations (version) VALUES ('20160818210814');

INSERT INTO schema_migrations (version) VALUES ('20160818210829');

INSERT INTO schema_migrations (version) VALUES ('20160818214034');

INSERT INTO schema_migrations (version) VALUES ('20160823152936');

INSERT INTO schema_migrations (version) VALUES ('20160824144038');

INSERT INTO schema_migrations (version) VALUES ('20160912193216');

INSERT INTO schema_migrations (version) VALUES ('20160922211250');

INSERT INTO schema_migrations (version) VALUES ('20161108201848');

INSERT INTO schema_migrations (version) VALUES ('20161114212017');

INSERT INTO schema_migrations (version) VALUES ('20161116185540');

INSERT INTO schema_migrations (version) VALUES ('20161129163813');

INSERT INTO schema_migrations (version) VALUES ('20161129220506');

INSERT INTO schema_migrations (version) VALUES ('20161130180731');

INSERT INTO schema_migrations (version) VALUES ('20161231030150');

INSERT INTO schema_migrations (version) VALUES ('20170109155648');

INSERT INTO schema_migrations (version) VALUES ('20170117165457');

INSERT INTO schema_migrations (version) VALUES ('20170123143357');

INSERT INTO schema_migrations (version) VALUES ('20170307181801');

INSERT INTO schema_migrations (version) VALUES ('20170308194234');

INSERT INTO schema_migrations (version) VALUES ('20170310004320');

INSERT INTO schema_migrations (version) VALUES ('20170316145527');

INSERT INTO schema_migrations (version) VALUES ('20170324144234');

INSERT INTO schema_migrations (version) VALUES ('20170324151205');

INSERT INTO schema_migrations (version) VALUES ('20170324173407');

INSERT INTO schema_migrations (version) VALUES ('20170327131456');

INSERT INTO schema_migrations (version) VALUES ('20170328175135');

INSERT INTO schema_migrations (version) VALUES ('20170417170423');

INSERT INTO schema_migrations (version) VALUES ('20170504135204');

INSERT INTO schema_migrations (version) VALUES ('20170712184838');

INSERT INTO schema_migrations (version) VALUES ('20170905212404');

INSERT INTO schema_migrations (version) VALUES ('20170907195659');

INSERT INTO schema_migrations (version) VALUES ('20170929180512');

INSERT INTO schema_migrations (version) VALUES ('20170929183330');

INSERT INTO schema_migrations (version) VALUES ('20170930010301');

