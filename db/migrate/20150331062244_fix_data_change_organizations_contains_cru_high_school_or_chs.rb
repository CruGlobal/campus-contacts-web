class FixDataChangeOrganizationsContainsCruHighSchoolOrChs < ActiveRecord::Migration
  def up
    remove_cru_name = "Cru High School"
    change_cru_name = "High School"
    cru_total = 0
    puts "###### Change '#{remove_cru_name}' in to '#{change_cru_name}' ######"
    Organization.where("name LIKE ?", "%#{remove_cru_name}%").each do |organization|
      puts "### Updating #{organization.name}"
      if organization.update_attributes(name: organization.name.gsub(remove_cru_name, change_cru_name))
        cru_total += 1
        puts "# #{organization.name}"
      else
        puts "~ Process 1: ERROR ~"
      end
    end

    puts " "
    puts "##############################"
    puts "##############################"
    puts " "

    remove_chs_name = "CHS"
    change_chs_name = "HS"
    chs_total = 0
    puts "###### Change '#{remove_chs_name}' in to '#{change_chs_name}' ######"
    Organization.where("name LIKE ?", "%#{remove_chs_name}%").each do |organization|
      puts "### Updating #{organization.name}"
      if organization.update_attributes(name: organization.name.gsub(remove_chs_name, change_chs_name))
        chs_total += 1
        puts "# #{organization.name}"
      else
        puts "~ Process 2: ERROR ~"
      end
    end
    puts "Total records: CRU: #{cru_total}, CHS: #{chs_total}"
  end

  def down
  end
end
