# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)
if SmsCarrier.all.empty?
  SmsCarrier.create(name: 'AllTel', moonshado_name: 'alltel', email: 'message.alltel.com')
  SmsCarrier.create(name: 'AT&T', moonshado_name: 'cingular', email: 'txt.att.net')
  SmsCarrier.create(name: 'Sprint', moonshado_name: 'sprint', email: 'messaging.sprintpcs.com')
  SmsCarrier.create(name: 'Verizon', moonshado_name: 'verizon', email: 'vtext.com')
  SmsCarrier.create(name: 'Bluegrass', moonshado_name: 'bluegrass', email: 'sms.bluecell.com')
  SmsCarrier.create(name: 'Cincinnati Bell', moonshado_name: 'cincinnati bell', email: 'mobile.att.net')
  SmsCarrier.create(name: 'Cricket', moonshado_name: 'cricket', email: 'sms.mycricket.com')
  SmsCarrier.create(name: 'Cellular One', moonshado_name: 'cellular one', email: 'mobile.cellularone.com')
  SmsCarrier.create(name: 'Inland', moonshado_name: 'inland', email: 'inlandlink.com')
  SmsCarrier.create(name: 'Metro PCS', moonshado_name: 'metro pcs', email: 'metropcs.sms.us')
  SmsCarrier.create(name: 'Nextel', moonshado_name: 'nextel', email: 'messaging.nextel.com')
  SmsCarrier.create(name: 'T-Mobile', moonshado_name: 'tmobile', email: 'tmomail.net')
  SmsCarrier.create(name: 'US Cellular', moonshado_name: 'uscell', email: 'uscc.textmsg.com')
  SmsCarrier.create(name: 'Virgin Mobile', moonshado_name: 'virgin', email: 'vmobl.com')
end

Role.create(name: 'Admin', i18n: 'admin', organization_id: 0)
Role.create(name: 'Contact', i18n: 'contact',  organization_id: 0)
Role.create(name: 'Involved', i18n: 'involved',  organization_id: 0)
Role.create(name: 'Leader', i18n: 'leader',  organization_id: 0)
Role.create(name: 'Alumni', i18n: 'alumni',  organization_id: 0)