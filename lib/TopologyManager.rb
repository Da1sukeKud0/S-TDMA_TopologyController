require "link"
require "json"
require "~/trema/topology/lib/routing"

# Topology information containing the list of known switches, ports,
# and links.
class TopologyManager
  Port = Struct.new(:dpid, :port_no) do
    alias_method :number, :port_no

    def self.create(attrs)
      new attrs.fetch(:dpid), attrs.fetch(:port_no)
    end

    def <=>(other)
      [dpid, number] <=> [other.dpid, other.number]
    end

    def to_s
      "#{format "%#x", dpid}:#{number}"
    end
  end

  attr_reader :links
  attr_reader :ports
  attr_reader :hosts
  attr_reader :graph

  def initialize
    @observers = []
    @ports = Hash.new { [].freeze }
    ## links[]: all links (only s2s)
    @links = []
    ## hosts{}: keyはホストのmac_address
    @hosts = Hash.new { [].freeze }
    ## topo[]: all links (s2s and s2h)
    @topo = []
    ## 経路決定アルゴリズムへのトポロジ受け渡し、経路探索を行うクラス
    @graph = Graph.new
  end

  def add_observer(observer)
    @observers << observer
  end

  def switches
    @ports.keys
  end

  def add_switch(dpid, ports)
    ports.each { |each| add_port(each) }
    maybe_send_handler :add_switch, dpid, self
  end

  def delete_switch(dpid)
    delete_port(@ports[dpid].pop) until @ports[dpid].empty?
    @ports.delete dpid
    maybe_send_handler :delete_switch, dpid, self
  end

  def add_port(port)
    @ports[port.dpid] += [port]
    maybe_send_handler :add_port, Port.new(port.dpid, port.number), self
  end

  def delete_port(port)
    @ports[port.dpid].delete_if { |each| each.number == port.number }
    maybe_send_handler :delete_port, Port.new(port.dpid, port.number), self
    maybe_delete_link port
  end

  def maybe_add_link(link)
    return if @links.include?(link)
    @links << link
    ## topo
    add_switch2switch_link link
    port_a = Port.new(link.dpid_a, link.port_a)
    port_b = Port.new(link.dpid_b, link.port_b)
    maybe_send_handler :add_link, port_a, port_b, self
  end

  def maybe_add_host(*host)
    # return if @hosts.include?(host)
    return if @hosts.key?(host[0])
    # @hosts << host
    hostStats = Hash.new { [].freeze }
    hostStats.store(:mac_address, host[0])
    hostStats.store(:ip_address, host[1])
    hostStats.store(:dpid, host[2])
    hostStats.store(:port_no, host[3])
    @hosts[host[0]] = hostStats
    ## topo
    add_switch2host_link hostStats
    mac_address, _ip_address, dpid, port_no = *host
    maybe_send_handler :add_host, mac_address, Port.new(dpid, port_no), self
  end

  ## アクセサ
  def getRoute(src_id, dst_id)
    @graph.getRoute(src_id, dst_id)
  end

  ## アクセサ
  def setGraph
    @graph.setGraph(@topo)
  end

  ## アクセサ
  def get_topo
    return @topo
  end

  private

  ## @topoをJSON形式で出力する
  ##
  def topoToJSON
    puts @topo
    File.open("/tmp/topology.json", "w") do |file|
      JSON.dump(@topo, file)
    end
  end

  ## @topoにs2sのリンクを追加する関数
  ##
  def add_switch2switch_link(link)
    l = Hash.new { [].freeze }
    l.store(:type, "switch2switch")
    l.store(:id_a, link.dpid_a)
    l.store(:port_a, link.port_a)
    l.store(:id_b, link.dpid_b)
    l.store(:port_b, link.port_b)
    @topo.push(l)
    # topo2json
  end

  ## @topoにs2hのリンクを追加する関数
  ##
  def add_switch2host_link(hostStats)
    l = Hash.new { [].freeze }
    l.store(:type, "switch2host")
    ## Switch
    l.store(:id_a, hostStats[:dpid])
    l.store(:port_a, hostStats[:port_no])
    ## Host (s2hの場合はid_portはなし)
    l.store(:mac_address, hostStats[:mac_address])
    @topo.push(l)
    # topo2json
  end

  ## @topoからs2s,s2hのリンクを削除する関数
  ##
  def delete_switch2switch_link(port)
    for each in @topo
      ## id_a, port_aおよびid_b, port_bと一致した場合に
      ## @topoからリンクを削除
      if (each[:id_a] == port.dpid) && (each[:port_a] == port.number)
        @topo -= [each]
        ## s2hの場合は@hostsからホストを削除
        @hosts.delete(each[:mac_address]) if each[:type] == "switch2host"
        # topo2json
      elsif (each[:id_b] == port.dpid) && (each[:port_b] == port.number)
        @topo -= [each]
        # topo2json
      end
    end
  end

  def maybe_delete_link(port)
    ## topo
    delete_switch2switch_link port
    @links.each do |each|
      next unless each.connect_to?(port)
      @links -= [each]
      port_a = Port.new(each.dpid_a, each.port_a)
      port_b = Port.new(each.dpid_b, each.port_b)
      maybe_send_handler :delete_link, port_a, port_b, self
    end
  end

  def maybe_send_handler(method, *args)
    @observers.each do |each|
      if each.respond_to?(:update)
        each.__send__ :update, method, args[0..-2], args.last
      end
      each.__send__ method, *args if each.respond_to?(method)
    end
  end
end
