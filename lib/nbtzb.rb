class Nbtzb

  def initialize
    @opts = {}

    @opts[:netbox] = {}
    @opts[:netbox][:host] = ENV['NETBOX_HOST']
    @opts[:netbox][:token] = ENV['NETBOX_TOKEN']

    @opts[:zabbix] = {}
    @opts[:zabbix][:host] = ENV['ZABBIX_HOST']
    @opts[:zabbix][:user] = ENV['ZABBIX_USER']
    @opts[:zabbix][:pass] = ENV['ZABBIX_PASS']

    @netbox = ApiNetbox.new @opts[:netbox]
    @zabbix = ApiZabbix.new @opts[:zabbix]

    @default_group = 'nbtzb'

    @devices = []
    @groups = {}
  end

  def sync
    load_groups
    sync_groups

    sync_hosts

    load_templates
    sync_templates
  end

end
