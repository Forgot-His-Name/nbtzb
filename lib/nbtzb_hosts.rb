class Nbtzb

  def sync_hosts
    hosts = load_hosts

    create_missed_hosts hosts
  end

  def load_hosts
    nb_hosts = []
    @netbox.get_devices.each do |host|
      host[:type] = :device
      nb_hosts << host
    end
    @netbox.get_vms.each do |host|
      host[:type] = :vm
      nb_hosts << host
    end
    zb_hosts = @zabbix.get_hosts
    compare_hosts nb_hosts, zb_hosts
  end

  def compare_hosts(nbs, zbs)
    hosts = {}

    nbs.each do |nbhost|
      name = nbhost['name']
      hosts[name] = nbhost

      zbs.each do |zbhost|
        next unless name == zbhost['host']

        hosts[name][:zabbix] = zbhost
        break
      end
    end

    hosts
  end

  def create_missed_hosts(list)
    list.each do |name, host|
      next if host[:zabbix]

      opts = {}
      if host[:type] == :vm
        opts[:iftype] = :agent
        opts[:useip] = 0
      else
        opts[:iftype] = :snmp
        opts[:useip] = 1
      end

      if host['primary_ip'] && host['primary_ip']['address']
        opts[:ip] = host['primary_ip']['address']
      else
        opts[:ip] = ''
        opts[:useip] = 0
      end

      opts[:dns] = name
      opts[:community] = '$SNMP_COMMUNITY'

      if host['config_context'] && host['config_context']['snmp']
        if host['config_context']['snmp']['community']
          opts[:community] = host['config_context']['snmp']['community']
        end
      end

      groupids = []
      groupids << @groups[@default_group]

      @zabbix.create_host name, groupids, opts
    end
  end
end
