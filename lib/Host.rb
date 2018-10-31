## ホスト
## Topology::@hosts{}への格納キーはmac_address
class Host
  def initialize(mac_address, ip_address, dpid, port_no)
    @mac_address = mac_address
    @ip_address = ip_address
    @dpid = dpid
    @port_no = port_no
  end

  attr_reader :mac_address
  attr_reader :ip_address
  attr_reader :dpid
  attr_reader :port_no
end
