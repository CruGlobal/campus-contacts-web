ActiveAdmin.register DashboardPost do
  filter :title
  filter :created_at
  
  form do |f|
    f.inputs "Content" do
      f.input :title
      f.input :context, :label => "Text"
      f.input :video, :label => "YouTube Video ID"
      f.input :visible
    end
    f.buttons
  end
  
  
  index do
    column :title
    column :video
    column :created_at
    column "Actions" do |post|
      ret = []
      ret << link_to("View", admin_dashboard_post_path(post))
      ret << link_to("Edit", edit_admin_dashboard_post_path(post))
      ret << link_to("Delete", admin_dashboard_post_path(post), :method => :delete, :confirm => "Are you sure?")
      raw ret.join(' ')
    end
  end
end
