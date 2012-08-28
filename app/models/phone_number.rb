require 'open-uri'
class PhoneNumber < ActiveRecord::Base
  @queue = :general
  belongs_to :carrier, class_name: 'SmsCarrier', foreign_key: 'carrier_id'
  
  belongs_to :person
  validates_presence_of :number, message: "can't be blank"
  
  before_create :set_primary
  before_save :clear_carrier_if_number_changed
  after_commit :async_update_carrier
  after_destroy :set_new_primary
  
  def self.strip_us_country_code(num)
    return unless num
    num = num.to_s.gsub(/[^\d]/, '')
    num.length == 11 && num.first == '1' ? num[1..-1] : num
  end
  
  def number=(num)
    if num
      self[:number] = PhoneNumber.strip_us_country_code(num)
    end
  end
  
  def pretty_number
    case number.length
    when 7
      "#{number[0..2]}-#{number[3..-1]}"
    when 10
      "(#{number[0..2]}) #{number[3..5]}-#{number[6..-1]}"
    else
      number
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
  
  protected
  
  def clear_carrier_if_number_changed
    if changed.include?('number')
      self.txt_to_email = nil
      self.carrier_id = nil
    end
  end
  
  def async_update_carrier
    async(:update_carrier)
  end

  def update_carrier
    unless txt_to_email
      # First see if this number is already in our db
      existing = PhoneNumber.where(number: number).where("txt_to_email is not null").order('email_updated_at desc').first
      if existing
        PhoneNumber.connection.update("update phone_numbers set carrier_id = #{existing.carrier_id}, txt_to_email = '#{existing.txt_to_email}', email_updated_at = '#{existing.email_updated_at.to_s(:db)}' where number = '#{number}'")
      else
        url = "https://api.data24-7.com/textat.php?username=support@missionhub.com&password=Windows7&p1=#{number}"
        xml = Nokogiri::XML(open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
        begin
          email = xml.xpath('.//sms_address').text
          carrier_name = xml.xpath('.//carrier_name').text
          carrier = SmsCarrier.find_or_create_by_data247_name(carrier_name)
          PhoneNumber.connection.update("update phone_numbers set carrier_id = #{carrier.id}, txt_to_email = '#{email}', email_updated_at = '#{Time.now.to_s(:db)}' where number = '#{number}'")
        rescue => e
          # cloudvox didn't like the number
          Airbrake.notify(e,
            :error_class => "Cloudvox Error",
            :error_message => "Error getting carrier from cloudvox",
            :parameters => {:cloudvox => xml.inspect}
          )
        end
      end
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
