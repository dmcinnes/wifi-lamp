Server  = require 'server'
require 'commands'

if file.list()['program'] then
  file.remove('program')
else
  require 'lamp'
end
