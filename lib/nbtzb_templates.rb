class Nbtzb

  def load_templates
    @templates = {}

    list = @zabbix.get_templates
    list.each do |item|
      name = item['host']
      @templates[name] = item
    end
  end

  def sync_templates
    devices = load_devices

    devices.each do |name, data|
      next unless data['zabbix']

      tids = []
      data['config_context'] = {} unless data['config_context']
      data['config_context']['zabbix_templates'] = [] unless data['config_context']['zabbix_templates']
      data['config_context']['zabbix_templates'].each do |tname|
        if @templates[tname]
          tids << { 'templateid' => @templates[tname]['templateid'], 'name' => tname }
        else
          puts "missed zabbix template '#{tname}'"
        end
      end

      next if data['zabbix']['parentTemplates'].sort == tids.sort

      tids_clear = []
      data['zabbix']['parentTemplates'].each do |item|
        tname = item['name']
        next if data['config_context']['zabbix_templates'].include? tname

        tids_clear << { 'templateid' => item['templateid'] }
      end

      hostid = data['zabbix']['hostid']
      @zabbix.update_templates(hostid, tids, tids_clear)
    end
  end

end
