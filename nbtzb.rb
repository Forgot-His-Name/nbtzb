require 'net/http'
require 'json'
require 'yaml'
require 'dotenv/load'

require_relative 'lib/api-netbox.rb'
require_relative 'lib/api-zabbix.rb'

require_relative 'lib/nbtzb.rb'
require_relative 'lib/nbtzb_devices.rb'
require_relative 'lib/nbtzb_groups.rb'
require_relative 'lib/nbtzb_templates.rb'

nbtzb = Nbtzb.new
nbtzb.sync
