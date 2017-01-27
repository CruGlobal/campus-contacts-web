# frozen_string_literal: true
class ReportMailer < ActionMailer::Base
  default from: '"MissionHub Support" <support@missionhub.com>'

  add_template_helper(EmailHelper)
  layout 'fancy_email'

  def all
    @org_message = 'all organizations in Missionhub'

    read_report

    to = %w(Matthew.Watts@cru.org Russ.l.Martin@cru.org Paul.Alexander@cru.org
            erik.butz@cru.org jenny.chau@cru.org spencer.oberstadt@cru.org)

    mail to: to,
         subject: almanac_subject('All'),
         template_name: 'report'
  end

  def cru
    @org_message = 'all sub-organizations under Cru'

    report = read_report(1)
    @label_counts = report.number_of_people_with_label(Label.default_cru_labels)

    to = %w(Matthew.Watts@cru.org ryan.mcreynolds@cru.org joseph.chau@cru.org)

    mail to: to,
         subject: almanac_subject('Cru'),
         template_name: 'report'
  end

  def p2c
    @org_message = 'all sub-organizations under P2C'

    report = read_report(ENV.fetch('POWER_TO_CHANGE_ORG_ID'))
    labels = Label.where(i18n: %w(growing_disciple ministering_disciple multiplying_disciple))
    @label_counts = report.number_of_people_with_label(labels)
    decision = Label.find_by(i18n: 'made_decision')
    @gained_decision = report.gained_label(decision)[decision.name]

    to = %w(Matthew.Watts@cru.org Russ.l.Martin@cru.org paul.hildebrand@p2c.com)

    mail to: to,
         subject: almanac_subject('Power2Change'),
         template_name: 'report'
  end

  def leader_digest(person_id)
    return unless @person = Person.find_by(id: person_id)
    orgs = @person.active_organizations
    return if orgs.empty?

    @org_reports = {}
    orgs.each do |org|
      read_report(org.id, false)
      next if @interaction_counts.blank?
      @org_reports[org.id] = {
        changed: @changed,
        interactions: @interaction_counts,
        new_contacts: @new_contacts
      }
    end
    return if @org_reports.blank?

    mail to: @person.primary_email_address, subject: 'Missionhub - Weekly Digest for ' + @person.first_name
  end

  private

  def read_report(org_id = nil, all_core = true)
    report = MinistryReport.new(start_date, end_date, org_id)
    @changed = report.status_changed_count
    @interaction_counts = report.interaction_counts(all_core)
    @new_contacts = report.new_contacts
    report
  end

  def almanac_subject(org)
    # there are emojis in here, even if rubymine doesn't show it
    "Missionhub - #{org} Organizations Farmers Almanac 🐣🐮🚜"
  end

  def end_date
    @end_date ||= DateTime.current.beginning_of_day
  end

  def start_date
    @start_date ||= end_date - 7.days
  end
end
