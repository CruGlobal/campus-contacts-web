class OrganizationalLabel < ActiveRecord::Base
  attr_accessible :added_by_id, :label_id, :organization_id, :person_id, :removed_date, :start_date,
    :created_at, :updated_at
  # added :created_at and :updated_at for migration only

  before_create :set_start_date

  belongs_to :person, :touch => true
  belongs_to :created_by, class_name: 'Person', foreign_key: 'added_by_id'
  belongs_to :label
  belongs_to :organization


  def archive
    update_attributes({:removed_date => Time.now})
  end

  def self.mass_update(new_labels, remove_labels, people, organization, added_by)
    OrganizationalLabel.where(label_id: new_labels, organization: organization, person_id: people).where.not(removed_date: nil)
        .update_all(removed_date: nil)
    OrganizationalLabel.where(label_id: new_labels, organization: organization, person_id: people, added_by_id: nil)
        .update_all(added_by_id: added_by.id)

    new_org_labels = []
    new_labels.each do |label_id|
      existing_ids = OrganizationalLabel.where(label_id: label_id, organization: organization, person_id: people)
                         .pluck(:person_id).map(&:to_s)
      (people - existing_ids).each do |person_id|
        new_org_labels << "(#{organization.id}, #{label_id}, #{person_id}, #{added_by.id}, \
                           '#{DateTime.now.to_s(:db)}', '#{DateTime.now.to_s(:db)}', '#{Date.today}')"
      end
    end

    if new_org_labels.any?
      # lets do a mass insert, because doing 1000 individual inserts is super slow
      OrganizationalLabel.connection.execute(
          "INSERT INTO organizational_labels (organization_id, label_id, person_id, added_by_id, \
           created_at, updated_at, start_date) VALUES #{new_org_labels.join(', ')}")
    end

    OrganizationalLabel.where(label_id: remove_labels, organization: organization,
                              person_id: people, removed_date: nil)
        .update_all(removed_date: Time.now)
  end

  private

  def set_start_date
    self.start_date = Date.today
    true
  end
end
