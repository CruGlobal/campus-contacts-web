Chef::Log.info("Running deploy/before_symlink.rb...")

Chef::Log.info("Symlinking #{release_path}/public/assets to #{new_resource.deploy_to}/shared/assets")

directory "#{new_resource.deploy_to}/shared/assets" do
  user new_resource.user
  action :create
end

link "#{release_path}/public/assets" do
  to "#{new_resource.deploy_to}/shared/assets"
end

rails_env = new_resource.environment["RAILS_ENV"]
Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

execute "rake assets:precompile" do
  user new_resource.user
  cwd release_path
  command "bundle exec rake assets:precompile"
  environment "RAILS_ENV" => rails_env
end
