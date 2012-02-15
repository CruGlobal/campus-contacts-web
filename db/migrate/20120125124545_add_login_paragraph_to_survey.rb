class AddLoginParagraphToSurvey < ActiveRecord::Migration
  def change
    add_column :mh_surveys, :login_paragraph, :string
  end
end
