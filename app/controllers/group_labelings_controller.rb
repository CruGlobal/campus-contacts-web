class GroupLabelingsController < ApplicationController
  def create
    @group = current_organization.groups.find(params[:group_id])
    authorize! :manage, @group
    @group_label = current_organization.group_labels.find(params[:group_label_id])
    GroupLabeling.create(:group_id => @group.id, :group_label_id => @group_label.id)
    render nothing: true
  end
  
  def destroy
    @group = current_organization.groups.find(params[:group_id])
    authorize! :manage, @group
    @group_labeling = @group.group_labelings.where(group_label_id: params[:id]).first
    @group_labeling.destroy
    
    render nothing: true
  end
end
