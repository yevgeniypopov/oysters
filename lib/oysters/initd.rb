require 'oysters'

Dir[File.dirname(__FILE__) + '/initd/*.rb'].each do |f|
  require f
end
