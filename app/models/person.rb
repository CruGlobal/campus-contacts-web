class Person < ActiveRecord::Base
  include Ccc::Person
  set_table_name 'ministry_person'
  set_primary_key 'personID'
  
  belongs_to :user, :class_name => 'User', :foreign_key => 'fk_ssmUserId'
  has_many :phone_numbers
  has_many :locations
  has_many :friends
  has_many :interests
  has_many :education_histories
  has_one :primary_phone_number, :class_name => "PhoneNumber", :foreign_key => "person_id", :conditions => {:primary => true}
  has_many :email_addresses
  has_one :primary_email_address, :class_name => "EmailAddress", :foreign_key => "person_id", :conditions => {:primary => true}
  has_many :organization_memberships
  has_many :organizations, :through => :organization_memberships
  has_one :primary_organization_membership, :class_name => "OrganizationMembership", :foreign_key => "person_id", :conditions => {:primary => true}
  has_one :primary_organization, :through => :primary_organization_membership, :source => :organization
  has_many :answer_sheets
  has_many :contact_assignments, :class_name => "ContactAssignment", :foreign_key => "assigned_to_id"
  has_many :assigned_tos, :class_name => "ContactAssignment", :foreign_key => "person_id"
  has_many :assigned_contacts, :through => :contact_assignments, :source => :assigned_to
  
  scope :who_answered, lambda {|question_sheet_id| includes(:answer_sheets).where(AnswerSheet.table_name + '.question_sheet_id' => question_sheet_id)}
  validates_presence_of :firstName, :lastName
  
  accepts_nested_attributes_for :email_addresses, :phone_numbers, :allow_destroy => true

  def to_s
    [preferredName.blank? ? firstName : preferredName, lastName].join(' ')
  end
  
  def firstName
    preferredName.blank? ? self[:firstName] : preferredName
  end
  
#We'll do this better at some point.  
#New->Create? Gets rid of the save in update_from_facebook  
  def self.create_from_facebook(data, authentication, response = nil)
    if response.nil?
      @response = MiniFB.get(authentication.token, authentication.uid)
    else
      @response = response
    end
    new_person = Person.create(:firstName => data['first_name'], :lastName => data['last_name'])
    new_person.update_from_facebook(data, authentication, @response)
    new_person.get_first_time_only_login_data(authentication, @response)
    
    new_person
  end
  
  def update_from_facebook(data, authentication, response = nil)
    response = MiniFB.get(authentication.token, authentication.uid) if response.nil?
    self.birth_date = DateTime.strptime(data['birthday'], '%m/%d/%Y') if birth_date.blank? && data['birthday'].present?
    self.gender = response.gender unless (response.gender.nil? && !gender.blank?)
    save!
    unless email_addresses.detect {|e| e.email == data['email']}
      email_addresses.create(:email => data['email'])
    end
    save
    get_location(authentication, response)
    self
  end
  
  def gender=(gender)
    if ['male','female'].include?(gender.to_s.downcase)
      self[:gender] = gender.downcase == 'male' ? '1' : '0'
    else
      self[:gender] = gender
    end
  end
  
  def gender
    if ['1','0'].include?(self[:gender])
      self[:gender] == '1' ? 'male' : 'female'
    else
      self[:gender]
    end
  end
  
  def email
    primary_email_address
  end
  
  def email=(val)
    email = primary_email_address || email_addresses.new
    email.email = val
    email.save
  end
  
  
  def get_first_time_only_login_data(authentication = nil, response = nil, person = nil)
    resp = nil
    resp2 = nil
    authentication = person.user.authentications.order("updated_at DESC").first unless authentication 
    get_education_history(authentication, response)
    if !response.nil?
      resp = TestFBResponses::FRIENDS 
      resp2 = TestFBResponses::INTERESTS
    end
    get_friends(authentication, resp)
    get_interests(authentication, resp2)
  end
  
  def get_friends(authentication, response = nil)
    if friends.count == 0 
      if response.nil?
         @friends = MiniFB.get(authentication.token, authentication.uid,:type => "friends")
      else @friends = response
      end
      @friends["data"].each do |friend|
        friends.create(:uid => friend['id'], :name => friend['name'], :person_id => personID.to_i, :provider => "facebook")
      end
    end
    @friends["data"].length  #return how many friend you got from facebook for testing
  end
  
  #
  def update_friends(authentication,response = nil)
      if response.nil?
         @friends = MiniFB.get(authentication.token, authentication.uid,:type => "friends")
      else @friends = response
      end
    @friends = @friends["data"]
    @removal = []
    @create = []
    @match = []
    @dbf = friends.reload
    
    @friends.each do |friend|
      @dbf.each do |dbf|
        if dbf['uid'] == friend.id
          @matching_friend = dbf if dbf['uid'] == friend.id
          break
        end
        @matching_friend = nil
      end
      if @matching_friend
        friends.find_by_uid(@matching_friend.uid).update_attributes(:name => friend['name']) unless @matching_friend.name.eql?(friend['name'])
        @match.push(@matching_friend.uid)
      elsif friends.find_by_uid(friend.id).nil? #uid's did not match && the DB is empty
        friends.create!(:uid => friend['id'], :name => friend['name'], :person_id => personID.to_i, :provider => "facebook")
        @create.push(friend['id'])
      end
    end
    @dbf = friends.reload
    
    @dbf.each do |dbf|
      if !( @match.include?(dbf.uid) || @create.include?(dbf.uid) )
        friend_to_delete = friends.select('id').where("uid = ?", dbf.uid).first
        id_to_destroy = friend_to_delete['id'].to_i
        Friend.destroy(id_to_destroy)
        @removal.push(dbf.uid)
      end
    end
    @removal.length + @create.length  #create way to test how many changes were made
  end
  
  def get_interests(authentication, response = nil)
    if response.nil?
      @interests = MiniFB.get(authentication.token, authentication.uid,:type => "interests")
    else @interests = response
    end
    @interests["data"].each do |interest|
      interests.find_or_initialize_by_interest_id_and_person_id_and_provider(interest['id'], personID.to_i, "facebook") do |i|
        i.provider = "facebook"
        i.category = interest['category']
        i.name = interest['name']
        i.interest_created_time = interest['created_time']
      end
      save
    end
    interests.count
  end
  
  def get_location(authentication, response = nil)
    if response.nil?
      @location = MiniFB.get(authentication.token, authentication.uid).location
    else @location = response.location
    end
    Location.find_or_create_by_location_id_and_name_and_person_id_and_provider(@location['id'], @location['name'], personID.to_i,"facebook") unless @location.nil?
  end
  
  def get_education_history(authentication, response = nil)
    if response.nil?
      @education = MiniFB.get(authentication.token, authentication.uid).education
    else @education = response.try(:education)
    end
    unless @education.nil?
      @education.each do |education|
        education_histories.find_or_initialize_by_school_id_and_person_id_and_provider(education.school.try(:id), personID.to_i, "facebook") do |e|
          e.year_id = education.year.try(:id) ? education.year.id : e.year_id
          e.year_name = education.year.try(:name) ? education.year.name : e.year_name
          e.school_type = education.try(:type) ? education.type : e.school_type
          e.school_name = education.school.try(:name) ? education.school.name : e.school_name
          unless education.try(:concentration).nil?
            0.upto(education.concentration.length-1) do |c|
              e["concentration_id#{c+1}"] = education.concentration[c].try(:id) ? education.concentration[c].id : e["concentration_id#{c+1}"]
              e["concentration_name#{c+1}"] = education.concentration[c].try(:name) ? education.concentration[c].name : e["concentration_name#{c+1}"]
            end
          end
          unless education.try(:degree).nil?
            e.degree_id = education.degree.try(:id) ? education.degree.id : e.degree_id
            e.degree_name = education.degree.try(:name) ? education.degree.name : e.degree_name
          end
          save!       
        end 
      end
    end
  end  
  
  def merge(other)
    # Phone Numbers
    phone_numbers.each do |pn|
      opn = other.phone_numbers.detect {|oa| oa.number == pn.number && oa.extension == pn.extension}
      pn.merge(opn) if opn
    end
    other.phone_numbers.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}
    
    # Email Addresses
    email_addresses.each do |pn|
      opn = other.email_addresses.detect {|oa| oa.email == pn.email}
      pn.merge(opn) if opn
    end
    other.email_addresses.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}
    
    # Organizational Memberships
    organization_memberships.each do |pn|
      opn = other.organization_memberships.detect {|oa| oa.organization_id == pn.organization_id}
      pn.merge(opn) if opn
    end
    other.organization_memberships.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}
    
    super
  end

  def to_hash
    fb_id = user.authentications.where(:provider => "facebook").order("updated_at DESC").first.uid
    hash = {}
    hash['id'] = self.user.userID.to_s
    hash['name'] = self.to_s
    hash['first_name'] = self.firstName
    hash['last_name'] = self.lastName
    hash['gender'] = self.gender
    hash['locale'] = user.locale ? user.locale : ""
    hash['fb_id'] = fb_id
    hash['birthday'] = self.birth_date.to_s
    hash['picture'] = "http://graph.facebook.com/#{fb_id}/picture"
    hash['interests'] = interests.collect(&:to_hash)
    hash['education'] = education_histories.collect(&:to_hash)
    locs = locations.order("updated_at DESC").first
    if !locs.nil?
      locs = locs.to_hash
    end
    hash['location'] = locs
    hash
  end
end
