class ChangeTableNames < ActiveRecord::Migration
  def change
    rename_table :mh_answer_sheets, :answer_sheets
    rename_table :mh_answers, :answers
    rename_table :mh_dashboard_posts, :dashboard_posts
    rename_table :mh_education_histories, :education_histories
    rename_table :mh_elements, :elements
    rename_table :mh_friends, :friends
    rename_table :mh_group_labelings, :group_labelings
    rename_table :mh_group_labels, :group_labels
    rename_table :mh_group_memberships, :group_memberships
    rename_table :mh_groups, :groups
    rename_table :mh_imports, :imports
    rename_table :mh_interests, :interests
    rename_table :mh_locations, :locations
    rename_table :mh_new_people, :new_people
    rename_table :mh_person_transfers, :person_transfers
    rename_table :mh_question_rules, :question_rules
    rename_table :mh_question_sheets, :question_sheets
    rename_table :mh_rules, :rules
    rename_table :mh_survey_elements, :survey_elements
    rename_table :mh_surveys, :surveys
    rename_table :ministry_newaddress, :addresses
    rename_table :ministry_person, :people
    rename_table :simplesecuritymanager_user, :users
  end

end