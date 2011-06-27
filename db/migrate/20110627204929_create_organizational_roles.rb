class CreateOrganizationalRoles < ActiveRecord::Migration
  def up
    create_table :organizational_roles do |t|
      t.integer :person_id
      t.integer :role_id
      t.date :start_date
      t.date :end_date
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
    
    # Convert old roles system over to new system
    contact = Role.find_by_i18n('contact').id
    admin = Role.find_by_i18n('admin').id
    leader = Role.find_by_i18n('leader').id
    %w[contact admin leader].each do |role|
      OrganizationMembership.where(role: role).each do |om|
        OrganizationalRole.create(role_id: eval(role), person_id: om.person_id)
      end
    end
  end
  
  def down
    drop_table :organizational_roles
  end
end
