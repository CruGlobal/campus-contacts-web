class Ccc::SiAnswerSheet < ActiveRecord::Base
  has_many :answers, class_name: 'Ccc::SiAnswer', foreign_key: :answer_sheet_id, dependent: :destroy
end
