# frozen_string_literal: true
class ReportMailer < ActionMailer::Base
  default from: '"MissionHub Support" <support@missionhub.com>'

  def all
    @org_message = 'all organizations in Missionhub'

    read_report

    to = %w(Matthew.Watts@cru.org Russ.l.Martin@cru.org Paul.Alexander@cru.org)

    ###
    # delete this override once this is ready to go
    to = %w(Matthew.Watts@cru.org Spencer.Oberstadt@cru.org)
    ###

    mail to: to,
         subject: subject('All'),
         template_name: 'report'
  end

  def cru
    @org_message = 'all sub-organizations under Cru'

    report = read_report(1)
    @label_counts = report.number_of_people_with_label(Label.default_cru_labels)

    to = %w(Matthew.Watts@cru.org ryan.mcreynolds@cru.org joseph.chau@cru.org)

    ###
    # delete this override once this is ready to go
    to = %w(Matthew.Watts@cru.org Spencer.Oberstadt@cru.org)
    ###

    mail to: to,
         subject: subject('Cru'),
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

    ###
    # delete this override once this is ready to go
    to = %w(Matthew.Watts@cru.org Spencer.Oberstadt@cru.org)
    ###

    mail to: to,
         subject: subject('Power2Change'),
         template_name: 'report'
  end

  private

  def read_report(org_id = nil)
    report = MinistryReport.new(start_date, end_date, org_id)
    @changed = report.status_changed_count
    @interaction_counts = report.interaction_counts
    @new_contacts = report.new_contacts
    report
  end

  def subject(org)
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
