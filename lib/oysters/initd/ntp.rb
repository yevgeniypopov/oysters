require 'oysters'

Oysters.with_configuration do
  namespace :initd do

    set :ntp_host, 'pool.ntp.org' unless exists?(:ntp_host)

    namespace :ntp do
      desc 'Installs and configures ntp service'
      task :install do
        sudo "yum install -y ntp;\
              sudo chkconfig ntpd on;\
              sudo service ntpd stop;\
              sleep 3;\
              if [[ ! `grep 'server #{ntp_host}' /etc/ntp.conf` ]];
              then
                  sudo sed -i '0,/^server /s//server #{ntp_host}\n&/' /etc/ntp.conf;\
              fi;\
              if [[ ! `grep '#{ntp_host}' /etc/ntp/step-tickers` ]];
              then
                  sudo sed -i '0,/^#.*$/s//&\n#{ntp_host}/' /etc/ntp/step-tickers;\
              fi;\
              sudo ntpdate #{ntp_host};\
              sleep 1;\
              sudo service ntpd start;
        "
      end
    end

  end
end
