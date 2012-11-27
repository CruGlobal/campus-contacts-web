ActiveAdmin.register Organization do

  filter :name
  filter :terminology
  filter :status, :as => :select, :collection => %w[requested active denied inactive]
  filter :created_at
  filter :updated_at

  form :partial => "form"

  index do
    column :name
    column 'Admins' do |org|
      org.admins.collect {|p| mail_to(p.email, p.to_s)}
    end
    column :terminology
    column :created_at
    column :updated_at
    column :show_sub_orgs
    column :status
    column "Actions" do |org|
      ret = []
      ret << link_to("View", admin_organization_path(org))
      ret << link_to("Edit", edit_admin_organization_path(org))
      ret << link_to("Delete", admin_organization_path(org), :method => :delete, :confirm => "Are you sure?")
      org.status_paths.events.each do |event|
        ret << link_to(event.to_s.titleize, "/admin/organizations/#{org.id}/t/#{event}", method: :post, class: "#{event} organization", confirm: "Are you sure you want to #{event} #{org}")
      end
      raw ret.join(' ')
    end
  end

  member_action :transition, :method => :post do
    org = Organization.find(params[:id])
    org.send(params[:transition] + '!') if org.status_paths.events.include?(params[:transition].to_sym)
    redirect_to '/admin/organizations', notice: "#{org} is now #{org.status}"
  end

  collection_action :approve, :method => :post do
    orgs = Organization.find(params[:bulk_ids])
    orgs.map do |org|
      begin
        Organization.transaction do
          org.approve!
        end
      # rescue StateMachine::InvalidTransition

      end
    end
    redirect_to :back
  end
end
