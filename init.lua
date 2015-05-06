Server  = require 'server'
require 'commands'

if not file.list()['program'] then
  -- insurance policy
  file.open('program', 'w')
  file.close()
  require 'lamp'
end

file.remove('program')
