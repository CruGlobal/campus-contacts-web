class GenerateCruStatuses < ActiveRecord::Migration
  def up
    if x = CruStatus.where(i18n: 'none').first_or_create
      x.update_attributes(name: "None")
    end
    if x = CruStatus.where(i18n: 'volunteer').first_or_create
      x.update_attributes(name: "Volunteer")
    end
    if x = CruStatus.where(i18n: 'affiliate').first_or_create
      x.update_attributes(name: "Affiliate")
    end
    if x = CruStatus.where(i18n: 'intern').first_or_create
      x.update_attributes(name: "Intern")
    end
    if x = CruStatus.where(i18n: 'part_time_staff').first_or_create
      x.update_attributes(name: "Part Time Field Staff")
    end
    if x = CruStatus.where(i18n: 'full_time_staff').first_or_create
      x.update_attributes(name: "Full Time Supported Staff")
    end
  end

  def down
  end
end
