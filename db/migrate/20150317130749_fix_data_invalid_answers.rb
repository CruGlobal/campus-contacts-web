class FixDataInvalidAnswers < ActiveRecord::Migration
  def up
    checkbox_element_ids = Element.where(kind: "ChoiceField", style: "checkbox").pluck(:id)
    answers = Answer.where(question_id: checkbox_element_ids).where("value LIKE ?", "%,%")
    new_answers = {}
    answers.each do |answer|
      options = answer.question.options
      unless options.include?(answer.value)
        answers_str = answer.value.split(",").collect(&:strip).reject{|x| !x.present?}.uniq
        sub_answers = []
        answers_str.each do |ans|
          ans = ans.strip
          if options.include?(ans)
            sub_answers << ans
            Answer.create(
              answer_sheet_id: answer.answer_sheet_id,
              question_id: answer.question_id,
              value: ans,
              short_value: ans,
              created_at: answer.created_at,
              updated_at: answer.updated_at
            )
          end
        end
        new_answers[answer.id] = sub_answers
        answer.destroy if sub_answers.present?
      end
    end
    puts new_answers.inspect
  end

  def down
  end
end
