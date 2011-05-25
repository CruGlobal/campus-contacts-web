class EducationHistory < ActiveRecord::Base
  set_table_name 'mh_education_history'
  belongs_to :person
  validates_presence_of :person_id, :school_id, :school_name, :provider, :on => :create, :message => "can't be blank"
end
