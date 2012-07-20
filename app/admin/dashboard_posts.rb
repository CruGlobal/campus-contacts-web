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
end
