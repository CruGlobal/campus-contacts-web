class AnswerSheetSerializer < ActiveModel::Serializer

  INCLUDES = [:answers, :survey]

  attributes :id, :survey_id, :created_at, :updated_at, :completed_at

  has_many :answers
  has_one :survey

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      include!(rel.to_sym) if INCLUDES.include?(rel.to_sym)
    end if includes
  end

  INCLUDES.each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end


end

