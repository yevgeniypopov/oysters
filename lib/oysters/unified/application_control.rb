require 'oysters'
require 'erb'

Oysters.with_configuration do
  namespace :unified do
    [:kewatcher, :resque_scheduler, :unicorn].each do |program|
      namespace "#{program}" do
        [:stop, :start, :restart].each do |action|
          desc "#{action.to_s.capitalize} #{program.to_s.capitalize}"
          task action do
            run "/etc/init.d/iris_#{program} #{action.to_s}", {:pty => true}
          end
        end
      end
    end
  end
end
