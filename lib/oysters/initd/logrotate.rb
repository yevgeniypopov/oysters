require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :initd do

    namespace :logrotate do
      desc 'Install logrotate config'
      task :install, roles: :app do
        log_path = Pathname.new(shared_path).join('log', "#{rails_env}.log").to_s
        tmp_file = "/tmp/#{application}_logs_#{rand}"
        location = File.expand_path('../../templates/logrotate_config.erb', __FILE__)
        config   = ERB.new(File.read(location))

        put config.result(binding), tmp_file
        sudo "mv #{tmp_file} /etc/logrotate.d/#{application}_logs"
      end
    end

  end
end
