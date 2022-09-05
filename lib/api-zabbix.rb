class ApiZabbix

  def initialize(opts)
    @opts = opts

    raise 'ZABBIX_HOST option not defined' unless @opts[:host]
    raise 'ZABBIX_USER option not defined' unless @opts[:user]
    raise 'ZABBIX_PASS option not defined' unless @opts[:pass]

    @api_counter = 0
    @api_token = get_auth_token
  end

  def make_api_call(data)
    @api_counter += 1

    url = "https://#{@opts[:host]}/api_jsonrpc.php"
    uri = URI.parse url
    headers = { 'Content-Type' => 'application/json' }
    req = Net::HTTP::Post.new uri, headers

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true

    req_data = data.clone
    req_data[:jsonrpc] = '2.0'
    req_data[:id] = @counter
    req_data[:auth] = @api_token if @api_token

    resp = http.request req, req_data.to_json
    resp_data = JSON.parse(resp.body)

    if resp_data['error']
      pp resp_data['error']

      raise 'zabbix api returns error'
    end

    resp_data['result']
  end

  def get_auth_token
    req = { method: 'user.login', params: { user: @opts[:user], password: @opts[:pass]} }

    data = make_api_call req
  end

  def get_devices
    req = { method: 'host.get', params: {} }
    req[:params][:output] = [ 'hostid', 'host' ]
    req[:params][:selectInterfaces] = [ 'interfaceid', 'ip' ]
    req[:params][:selectGroups] = [ 'groupid', 'name' ]
    req[:params][:selectParentTemplates] = [ 'templateid', 'name' ]

    data = make_api_call req
  end

  def create_device(name, groupids, opts )
    req = { method: 'host.create', params: {} }
    req[:params][:host] = name
    req[:params][:groups] = groupids.map { |id| { groupid: id } }
    req[:params][:interfaces] = [ interface_params(opts) ]

    data = make_api_call req
  end

  def interface_params(opts)
    result = {}

    ip, _mask = opts[:ip].split('/')

    result[:main] = 1
    result[:ip] = ip
    result[:dns] = ''
    result[:useip] = 0

    if opts[:dns]
      result[:dns] = opts[:dns]
      result[:useip] = 1
    end

    case opts[:iftype]
    when :snmp
      result[:type] = 2
      result[:port] = '161'
      result[:details] = { version: 2 }
      result[:details][:community] = opts[:community]
    when :agent
      result[:type] = 1
      result[:port] = '10050'
    end

    result
  end

  def get_groups
    req = { method: 'hostgroup.get', params: {} }

    data = make_api_call req
  end

  def create_group(name)
    req = { method: 'hostgroup.create', params: {} }
    req[:params][:name] = name

    data = make_api_call req
  end

  def get_templates
    req = { method: 'template.get', params: {} }

    data = make_api_call req
  end

  def update_templates(hostid, tids, tids_clear)
    req = { method: 'host.update', params: {} }
    req[:params][:hostid] = hostid
    req[:params][:templates] = tids
    req[:params][:templates_clear] = tids_clear

    data = make_api_call req
  end

end
