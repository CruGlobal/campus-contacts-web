class CruStatus < ActiveRecord::Base
  DEFAULT = %w(none volunteer affiliate intern part_time_staff full_time_staff)
  attr_accessible :i18n, :name, :organization_id

  def self.none
    @none ||= find_by_i18n('none')
  end

  def self.volunteer
    @volunteer ||= find_by_i18n('volunteer')
  end

  def self.affiliate
    @affiliate ||= find_by_i18n('affiliate')
  end

  def self.intern
    @intern ||= find_by_i18n('intern')
  end

  def self.part_time_staff
    @part_time_staff ||= find_by_i18n('part_time_staff')
  end

  def self.full_time_staff
    @full_time_staff ||= find_by_i18n('full_time_staff')
  end

  def to_s
    name
  end
end
