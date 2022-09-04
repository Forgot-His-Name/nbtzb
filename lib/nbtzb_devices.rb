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

      ip = data['primary_ip']['address']

      groupids = []
      groupids << @groups[@default_group]

      @zabbix.create_device name, groupids, ip
    end
  end
end
