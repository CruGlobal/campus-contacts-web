class AnswerSerializer < ActiveModel::Serializer

  attributes :id, :question_id, :value
  
  def value 
    if object.value.blank?
      return nil
    else
      return object.value
    end
  end
end