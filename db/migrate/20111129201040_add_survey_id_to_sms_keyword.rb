class Survey < ActiveRecord::Base
  set_table_name 'mh_surveys'
  belongs_to :organization
end

class QuestionSheet < ActiveRecord::Base
  set_table_name 'mh_question_sheets'
  belongs_to :questionnable, :polymorphic => true
end  
  
class AddSurveyIdToSmsKeyword < ActiveRecord::Migration
  def up
    add_column :sms_keywords, :survey_id, :integer
    add_index :sms_keywords, :survey_id
    
    # Change question_pages to surveys
    drop_table :mh_surveys
    rename_table :mh_pages, :mh_surveys
    remove_column :mh_surveys, :no_cache
    remove_column :mh_surveys, :hidden
    remove_column :mh_surveys, :number
    rename_column :mh_surveys, :label, :title
    change_table :mh_surveys do |t|
      t.integer :organization_id
      t.timestamps
    end
    add_index :mh_surveys, :organization_id
    Survey.all.each do |survey|
      qs = QuestionSheet.find_by_id(survey.question_sheet_id)
      if qs
        keyword = qs.questionnable
        if keyword
          keyword.update_column(:survey_id, survey.id)
          survey.update_column(:organization_id, keyword.organization_id)
          survey.update_column(:updated_at, keyword.updated_at)
          survey.update_column(:created_at, keyword.created_at)
          survey.update_column(:title, "Survey for: " + keyword.keyword)
        else
          survey.update_column(:title, qs.label)
        end
      end
    end
  end
  
  def down
    create_table :mh_surveys do |t|
      t.string :title
      t.belongs_to :organization

      t.timestamps
    end
    add_index :mh_surveys, :organization_id
    remove_column :sms_keywords, :survey_id
    rename_table :mh_surveys, :mh_pages
    add_column :mh_surveys, :no_cache, :boolean, :default => false
    add_column :mh_surveys, :hidden, :boolean, :default => false
    add_column :mh_surveys, :number, :integer
    remove_column :mh_surveys, :organization_id
    remove_column :mh_surveys, :updated_at
    remove_column :mh_surveys, :created_at
    rename_column :mh_surveys, :title, :label
    rename_table :mh_survey_elements, :mh_page_elements
  end
end