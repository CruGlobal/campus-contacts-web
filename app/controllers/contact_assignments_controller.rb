class ContactAssignmentsController < ApplicationController
  def create
    @organization = Organization.find(params[:org_id])
    # @keyword = SmsKeyword.find(params[:keyword])
    @question_sheets = @organization.question_sheets
    ContactAssignment.where(:person_id => params[:ids], :question_sheet_id => @question_sheets).destroy_all
    if params[:assign_to].present?
      @assign_to = Person.find(params[:assign_to])
      params[:ids].each do |id|
        #made it loop through question_sheets, so that all question_sheets are assigned to one person.  not sure if this is the desired outcome.  need to modify the counts if you want to do this.
        @question_sheets.collect(&:id).each do |x|
          ContactAssignment.create!(:person_id => id, :question_sheet_id => x, :assigned_to_id => @assign_to.id)
        end
      end
    else
      
    end
    render :nothing => true
  end
end
