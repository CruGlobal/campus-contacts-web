class FixDataRemoveBlankAnswers < ActiveRecord::Migration
  def up
    Answer.where("value IS NULL OR value = ''").delete_all
  end

  def down
  end
end
