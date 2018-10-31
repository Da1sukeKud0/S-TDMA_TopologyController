## ホスト
## 以下のホスト情報にTopology::@hosts{}でのindex番号を付加
## Topology::@hosts{}への格納キーはmac_address
class Host
  def initialize(hst_id, mac_address, ip_address, dpid, port_no)
    @hst_id = hst_id
    @mac_address = mac_address
    @ip_address = ip_address
    @dpid = dpid
    @port_no = port_no
  end
  attr_reader :hst_id
  attr_reader :mac_address
  attr_reader :ip_address
  attr_reader :dpid
  attr_reader :port_no
end
