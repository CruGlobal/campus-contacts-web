ActiveAdmin.register SmsKeyword do
  filter :keyword
  filter :state, :as => :select, :collection => %w[requested active denied inactive]
  
  index do
    column 'User' do |keyword|
      "#{keyword.user.person} (#{keyword.user.sms_keywords.length})"
    end
    column :keyword
    column 'Organization' do |keyword|
      "#{keyword.organization} (#{keyword.organization.keywords.length})"
    end
    column :organization
    column :state
    column :explanation
    column :initial_response
    column :post_survey_message
    column :created_at
    column :updated_at
    column "Actions" do |keyword|
      ret = []
      ret << link_to("View", admin_sms_keyword_path(keyword))
      ret << link_to("Edit", edit_admin_sms_keyword_path(keyword))
      ret << link_to("Delete", admin_sms_keyword_path(keyword), :method => :destroy)
      keyword.state_paths.events.each do |event|
        ret << link_to(event.to_s.titleize, "/admin/sms_keywords/#{keyword.id}/t/#{event}", method: :post, class: "#{event} keyword", confirm: "Are you sure you want to #{event} #{keyword}")
      end 
      raw ret.join(' ')
    end
  end
  
  form :partial => "form"

  member_action :transition, :method => :post do
    keyword = SmsKeyword.find(params[:id])
    keyword.send(params[:transition] + '!') if keyword.state_paths.events.include?(params[:transition].to_sym)
    redirect_to '/admin/sms_keywords', notice: "#{keyword.keyword} is now #{keyword.state}"
  end
  
  collection_action :approve, :method => :post do
    keywords = SmsKeyword.find(params[:bulk_ids])
    keywords.map do |keyword| 
      begin
        SmsKeyword.transaction do
          keyword.approve!
        end
      # rescue StateMachine::InvalidTransition
        
      end
    end
    redirect_to :back
  end
end
