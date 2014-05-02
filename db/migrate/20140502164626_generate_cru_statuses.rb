class GenerateCruStatuses < ActiveRecord::Migration
  def up
    CruStatus.find_or_create_by_i18n('none', name: "None")
    CruStatus.find_or_create_by_i18n('volunteer', name: "Volunteer")
    CruStatus.find_or_create_by_i18n('affiliate', name: "Affiliate")
    CruStatus.find_or_create_by_i18n('intern', name: "Intern")
    CruStatus.find_or_create_by_i18n('part_time_staff', name: "Part Time Field Staff")
    CruStatus.find_or_create_by_i18n('full_time_staff', name: "Full Time Supported Staff")
  end

  def down
  end
end
