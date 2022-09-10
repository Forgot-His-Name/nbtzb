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
    hosts = load_hosts

    hosts.each do |name, host|
      next unless host[:zabbix]

      tids = []
      conf = host['config_context'] ? host['config_context'] : {}

      tlist = conf['zabbix_templates'] ? conf['zabbix_templates'] : []
      tlist.each do |tname|
        if @templates[tname]
          tids << { 'templateid' => @templates[tname]['templateid'], 'name' => tname }
        else
          puts "missed zabbix template '#{tname}'"
        end
      end

      current_ids = host[:zabbix]['parentTemplates'].map { |item| item['templateid'] }.sort
      target_ids = tids.map { |item| item['templateid'] }.sort

      next if current_ids == target_ids

      tids_clear = []
      host[:zabbix]['parentTemplates'].each do |item|
        tname = item['name']
        next if tlist.include? tname

        tids_clear << { 'templateid' => item['templateid'] }
      end

      hostid = host[:zabbix]['hostid']
      @zabbix.update_templates(hostid, tids, tids_clear)
    end
  end

end
