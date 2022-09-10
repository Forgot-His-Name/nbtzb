class ApiNetbox

  def initialize(opts)
    @opts = opts

    raise 'NETBOX_HOST option not defined' unless @opts[:host]
    raise 'NETBOX_TOKEN option not defined' unless @opts[:token]
  end

  def make_api_call(entrypoint)
    url = "https://#{@opts[:host]}/api/#{entrypoint}"
    uri = URI.parse url
    headers = { 'Content-Type' => 'application/json' }
    headers['Authorization'] = "TOKEN #{@opts[:token]}"
    req = Net::HTTP::Get.new uri, headers

    http = Net::HTTP.new uri.host, uri.port
    http.use_ssl = true

    resp = http.request req
    resp_data = JSON.parse(resp.body)

    if resp_data['error']
      pp resp_data['error']

      raise 'zabbix api returns error'
    end

    resp_data['results']
  end

  def get_devices
    make_api_call 'dcim/devices.json'
  end

  def get_vms
    make_api_call 'virtualization/virtual-machines.json'
  end

end
