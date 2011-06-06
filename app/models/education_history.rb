class EducationHistory < ActiveRecord::Base
  set_table_name 'mh_education_history'
  belongs_to :person
  validates_presence_of :person_id, :school_id, :school_name, :provider, :school_type, :on => :create, :message => "can't be blank"

  def to_hash
    hash = {}
    hash['school'] = {'id' => school_id, 'name' => school_name}
    hash['type'] = school_type
    hash['year'] = {'id' => year_id, 'name' => year_name.to_s} unless year_name.nil?
    concentration = []
    1.upto(3) do |c|
      concentration.push({'id' => eval("concentration_id#{c}"), 'name' => eval("concentration_name#{c}")}) unless eval("concentration_id#{c}").nil?
    end
    hash['concentration'] = concentration unless concentration.empty?
    hash['degree'] = {'id' => degree_id, 'name' => degree_name} unless degree_name.nil?
    hash['provider'] = provider
    hash
  end
  
  def self.get_education_history_hash(person_id)
    eh = EducationHistory.where("person_id = ?", person_id)
    eh.collect(&:to_hash)
  end
  
end
