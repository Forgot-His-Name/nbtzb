class Nbtzb

  def sync_devices
    devices = load_devices

    create_missed_devices devices
  end

  def load_devices
    nevices = @netbox.get_devices
    zevices = @zabbix.get_devices
    compare_devices nevices, zevices
  end

  def compare_devices(nevices, zevices)
    devices = {}

    nevices.each do |nevice|
      name = nevice['name']
      devices[name] = nevice

      zevices.each do |zevice|
        next unless name == zevice['host']

        devices[name]['zabbix'] = zevice
        break
      end
    end

    devices
  end

  def create_missed_devices(devices)
    devices.each do |name, data|
      next if data['zabbix']

      opts = {}
      opts[:iftype] = :snmp
      opts[:ip] = data['primary_ip']['address']
      opts[:dns] = ''
      opts[:community] = '$SNMP_COMMUNITY'

      if data['config_context'] && data['config_context']['snmp']
        if data['config_context']['snmp']['community']
          opts[:community] = data['config_context']['snmp']['community']
        end
      end

      groupids = []
      groupids << @groups[@default_group]

      @zabbix.create_device name, groupids, opts
    end
  end
end
