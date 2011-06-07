class ContactAssignmentsController < ApplicationController
  def create
    @organization = Organization.find(params[:org_id])
    # @keyword = SmsKeyword.find(params[:keyword])
    @question_sheets = @organization.question_sheets
    @assign_to = Person.find(params[:assign_to])

    
    ContactAssignment.where(:person_id => params[:ids], :question_sheet_id => @question_sheets).destroy_all
    params[:ids].each do |id|
      ContactAssignment.create!(:person_id => id, :question_sheet_id => @question_sheets, :assigned_to_id => @assign_to.id)
    end
    render :nothing => true
  end
end
