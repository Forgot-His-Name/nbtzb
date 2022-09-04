class Nbtzb

  def load_groups
    @groups = {}

    list = @zabbix.get_groups
    list.each do |group|
      name = group['name']
      @groups[name] = group['groupid']
    end
  end

  def sync_groups
    load_groups
    return true if @groups[@default_group]

    @zabbix.create_group @default_group
    load_groups
  end

end
