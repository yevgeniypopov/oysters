require 'oysters'

Oysters.with_configuration do

  namespace :dalli do
    desc 'Clear cache'
    task :clear_cache, :roles => :memcache do
      run "cd #{latest_release}; bundle exec rails runner -e #{rails_env} 'Rails.cache.clear'"
    end
  end

end
