npm install --production
bundle exec rake assets:clobber RAILS_ENV=production &&
bundle exec rake assets:precompile RAILS_ENV=production
