require 'open-uri'
require 'async'
class PhoneNumber < ActiveRecord::Base
  include Async
  include Sidekiq::Worker
  sidekiq_options unique: true
	TYPES = {"Mobile" => "mobile", "Home" => "home", "Work" => "work"}

  has_paper_trail :on => [:destroy],
                  :meta => { person_id: :person_id }

  attr_accessible :number, :extension, :person_id, :location, :primary, :not_mobile, :txt_to_email, :carrier_id, :email_updated_at

  belongs_to :carrier, class_name: 'SmsCarrier', foreign_key: 'carrier_id'
  belongs_to :person, touch: true

  validate do |value|
    # Handle number format
    phone_number = value.number_before_type_cast || value.number || nil
    if phone_number.present?
      unless (phone_number =~ /^(\d|\+|\.|\ |\/|\(|\)|\-){1,100}$/)
        errors.add(:number, "must be numeric")
      end
    else
      errors.add(:number, "can't be blank")
    end
  end
  #validates_uniqueness_of :number, on: :create, message: "already exists"
  validates_uniqueness_of :number, scope: :person_id, on: :update, message: "already exists"

  before_create :set_primary
  before_save :clear_carrier_if_number_changed, :strip_us_country_code
  after_destroy :set_new_primary

  def not_mobile!
    update_column(:not_mobile, true)
    return self
  end

  def active_for_org?(org)
    !SmsUnsubscribe.where(phone_number: number, organization_id: org.id).present?
  end

  def inactive_from_orgs
    SmsUnsubscribe.where(phone_number: number).pluck(:organization_id)
  end

  def self.strip_us_country_code(num)
    return unless num
    num = num.to_s.strip.gsub(/[^\d|\+]/, '')
    num.length == 11 && num.first == '1' ? num[1..-1] : num
  end

  def strip_us_country_code
    self[:number] = PhoneNumber.strip_us_country_code(number)
  end

  def pretty_number
    PhoneNumber.prettify(number)
  end

  def self.prettify(number)
    case number
    # Hungary
    when number =~ /^\+36/
      "#{number[0..2]} #{number[3]} #{number[4..6]}-#{number[7..10]}"
    when number =~ /^06/
      area_code = number.length == 10 ? number[2] : number[2..3]
      "#{number[0..1]} #{area_code} #{number[-7..-5]}-#{number[-4..-1]}"
    else
      # General US formatting
      case number.length
      when 7
        "#{number[0..2]}-#{number[3..-1]}"
      when 8
        "#{number[0]} #{number[-7..-5]}-#{number[-4..-1]}"
      when 9
        "#{number[0..1]} #{number[-7..-5]}-#{number[-4..-1]}"
      when 10
        "(#{number[0..2]}) #{number[3..5]}-#{number[6..-1]}"
      when 11
        "(#{number[0..3]}) #{number[4..6]}-#{number[7..-1]}"
      else
        number
      end
    end
  end

  def email_address
    # number + '@' + person.primary_phone_number.carrier.email
    txt_to_email
  end

  def number_with_country_code
    number.length == 10 ? '1' + number : number
  end

  def merge(other)
    PhoneNumber.transaction do
      %w{extension location primary}.each do |k, v|
        next if v == other.attributes[k]
        self[k] = case
                  when other.attributes[k].blank? then v
                  when v.blank? then other.attributes[k]
                  else
                    other.updated_at > updated_at ? other.attributes[k] : v
                  end
      end
      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.destroy
      save(validate: false)
    end
  end

  def same_as(other_number)
    PhoneNumber.strip_us_country_code(number) == PhoneNumber.strip_us_country_code(other_number)
  end

  protected

  def clear_carrier_if_number_changed
    if changed.include?('number')
      self.txt_to_email = nil
      self.carrier_id = nil
    end
  end

  def set_primary
    if person
      self.primary = (person.primary_phone_number ? false : true)
    end
    true
  end

  def set_new_primary
    if self.primary?
      if person && person.phone_numbers.present?
        person.phone_numbers.first.update_attribute(:primary, true)
      end
    end
    true
  end

  def normalize_carrier(name)
    case name
    when /VERIZON/, /BELL ATLANTIC/
      'verizon'
    when /SPRINT/
      'sprint'
    when /CINGULAR/
      'cingular'
    when /NEXTEL/
      'nextel'
    when /T-MOBILE/, /AERIAL COMMUNICATIONS/
      't-mobile'
    when /WESTERN WIRELESS/
      'western wireless'
    when /OMNIPOINT/
      'omnipoint'
    when /POWERTEL/
      'powertel'
    when /ALLTEL/
      'alltel'
    when /CRICKET/
      'cricket'
    when /UNITED STATES CELLULAR/
      'us cellular'
    when /ELTOPIA COMMUNICATIONS/
      'eltopia'
    when /AMERITECH/
      'ameritech'
    when /SOUTHERN BELL/, /BELLSOUTH/
      'bell south'
    when /SOUTHWESTERN BELL/
      'SOUTHWESTERN BELL'
    when /CINCINNATI BELL/
      'CINCINNATI BELL'
    when /CELLCOM/
      'CELLCOM'
    when /METRO PCS/, /METRO SOUTHWEST PCS/
      'METRO PCS'
    when /XO/
      'xo'
    when /BANDWIDTH.COM/
      'BANDWIDTH.COM'
    when /LEVEL 3 COMMUNICATIONS/
      'LEVEL 3 COMMUNICATIONS'
    when /CENTURYTEL/
      'CENTURYTEL'
    when /360NETWORKS/
      '360NETWORKS'
    when /ACS/
      'ACS'
    when /BROADWING/
      'BROADWING'
    when /CABLEVISION/
      'CABLEVISION'
    when /CENTENNIAL/
      'CENTENNIAL'
    when /CENTRAL/
      'CENTRAL'
    when /CHARTER FIBERLINK/
      'CHARTER FIBERLINK'
    when /CENTRAL/
      'CENTRAL'
    when /CHOICE ONE COMMUNICATIONS/
      'CHOICE ONE COMMUNICATIONS'
    when /FRONTIER/, /CITIZENS/
      'FRONTIER'
    when /CITYNET/
      'CITYNET'
    when /COMCAST/
      'COMCAST'
    when /COMMPARTNERS/
      'COMMPARTNERS'
    when /COX/
      'COX'
    when /DELTACOM/
      'DELTACOM'
    when /INTEGRA/
      'INTEGRA'
    when /EMBARQ/
      'EMBARQ'
    when /ESCHELON/
      'ESCHELON'
    when /GLOBAL CROSSING/
      'GLOBAL CROSSING'
    when /ICG TELECOM/
      'ICG TELECOM'
    when /ESCHELON/
      'ESCHELON'
    when /INTERMEDIA/
      'INTERMEDIA'
    when /MCI WORLDCOM/, /MCIMETRO/
      'mci'
    when /MPOWER/
      'MPOWER'
    when /NEUTRAL TANDEM/
      'NEUTRAL TANDEM'
    when /MPOWER/
      'MPOWER'
    when /NUVOX COMMUNICATIONS/
      'NUVOX COMMUNICATIONS'
    when /PAC - WEST TELECOMM/
      'PAC - WEST TELECOMM'
    when /PACIFIC BELL/
      'pacific bell'
    when /PAETEC COMMUNICATIONS/
      'PAETEC COMMUNICATIONS'
    when /RCN/
      'RCN'
    when /AT&T/
      'att'
    when /SUREWEST/
      'SUREWEST'
    when /TCG/
      'TCG'
    when /TELCOVE/
      'TELCOVE'
    when /TIME WARNER/
      'TIME WARNER'
    when /TW TELECOM/
      'TW TELECOM'
    when /UNITED TEL/
      'UNITED TEL'
    when /US LEC/
      'US LEC'
    when /WINDSTREAM/
      'WINDSTREAM'
    when /YMAX COMMUNICATIONS/
      'YMAX COMMUNICATIONS'
    else
      carrier
    end
  end
end
