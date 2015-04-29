require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :initd do

    namespace :logrotate do
      desc 'Install logrotate config'
      task :install, roles: :app do
        environment = Rails.env
        log_path = [ Pathname.new(shared_path).join('log', "#{environment}.log").to_s ]

        if application == 'oiv-ui'
          %W(#{environment}_delayed_job.log #{environment}_security_audit.log unicorn_#{environment}.stderr.log).each do |log|
            log_path << Pathname.new(shared_path).join('log', log).to_s
          end
        end

        conf_path = "/etc/logrotate.d/#{application}_logs"
        log_path  = log_path.join(' ')
        tmp_file  = "/tmp/#{application}_logs_#{rand}"
        location  = File.expand_path('../../templates/logrotate_config.erb', __FILE__)
        config    = ERB.new(File.read(location))

        put config.result(binding), tmp_file
        sudo "mv #{tmp_file} #{conf_path}"

        sudo "logrotate #{conf_path}"
      end
    end

  end
end
