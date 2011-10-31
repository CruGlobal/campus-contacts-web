require 'resque/tasks'
task "resque:setup" => :environment do
end

task "answer_comments" => :environment do
  OrganizationalRole.contact.includes(:organization, {person: :answer_sheets}).each do |role|
    OrganizationalRole.transaction do
      next unless role.person && role.person.answer_sheets.present?
      organization = role.organization
      questions = organization.all_questions
      FollowupComment.create_from_survey(organization, role.person, organization.all_questions, role.person.answer_sheets, 'uncontacted', role.created_at)
    end
  end
end

task "carriers" => :environment do
  # require 'hpricot'
  require 'net/http'
  PhoneNumber.connection.select_values("select distinct(number) as number from phone_numbers where carrier is null or carrier = ''").each do |number|
    uri = URI.parse("http://digits.cloudvox.com/#{number}.json")
    response = Net::HTTP.get(uri)
    puts response
    begin
      json = JSON.parse(response)
      carrier = normalize(json['allocation']['carrier_name'])
      PhoneNumber.connection.update("update phone_numbers set carrier = '#{carrier}' where number = '#{number}'")
    rescue
      # PhoneNumber.where(:number => number).collect(&:destroy)
    end
    time_to_sleep = rand(5) + 2
    puts "Sleeping #{time_to_sleep} seconds"
    sleep(time_to_sleep)
  end
end


def normalize(carrier)
  case carrier
  when /VERIZON/, /BELL ATLANTIC/
    'verizon'
  when /SPRINT/
    'sprint'
  when /CINGULAR/
    'cingular'
  when /NEXTEL/
    'nextel'
  when /T-MOBILE/
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