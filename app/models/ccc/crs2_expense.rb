class Ccc::Crs2Expense < ActiveRecord::Base
  self.table_name = 'crs2_expense'
  has_many :crs2_additional_expenses_items, class_name: 'Ccc::Crs2AdditionalExpensesItem'
  belongs_to :crs2_conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
end
