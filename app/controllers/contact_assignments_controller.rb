class ContactAssignmentsController < ApplicationController
  def create
    @keyword = SmsKeyword.find(params[:keyword])
    @question_sheet = @keyword.question_sheet
    @assign_to = Person.find(params[:assign_to])
    @organization = @keyword.organization
    
    ContactAssignment.where(:person_id => params[:ids], :question_sheet_id => @question_sheet.id).destroy_all
    params[:ids].each do |id|
      ContactAssignment.create!(:person_id => id, :question_sheet_id => @question_sheet.id, :assigned_to_id => @assign_to.id)
    end
  end
end
