# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( jquery-1.7.2.min.js jquery-ui-1.8.12.js welcome.css bootstrap.js qe/icons/* highcharts.js highcharts-more.js no_left_sidebar.css plain.css)
Rails.application.config.assets.precompile += %w( welcome.js )
Rails.application.config.assets.precompile += %w( bootstrap.css )
Rails.application.config.assets.precompile += %w( legacy_bootstrap.css )
Rails.application.config.assets.precompile += %w( country-region-data/data.json )
