class Ccc::Crs2ExpenseSelection < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_expense_selection'
  belongs_to :crs2_additional_expenses_item, class_name: 'Ccc::Crs2AdditionalExpensesItem', foreign_key: :expense_usage_id
  belongs_to :crs2_registrant, class_name: 'Ccc::Crs2Registrant', foreign_key: :registrant_id
  has_many :crs2_transactions, class_name: 'Ccc::Crs2Transaction'
end
