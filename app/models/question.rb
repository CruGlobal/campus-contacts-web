require_dependency Rails.root.join('vendor','plugins','questionnaire_engine','app','models','question').to_s

class Question < Element
  def get_api_question_hash
    hash = {}
    hash[:kind] = kind
    hash[:label] = label
    hash[:style] = style
    hash[:required] = required
    hash[:content] = content
    hash
  end
end