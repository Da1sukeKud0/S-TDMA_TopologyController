require "link"
require "json"
require "host"

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
  attr_reader :topo

  def initialize
    @observers = []
    @ports = Hash.new { [].freeze }
    @links = [] ## links[]: all links (only s2s)
    @hosts = Hash.new { [].freeze } ## hosts{}: keyはホストのmac_address
    # @mac_table = Hash.new ## ホストの識別名(h1,h2,,,hn)とmac_addressの対応
    @topo = [] ## topo[]: all links (s2s and s2h)
    ## 経路決定アルゴリズムへのトポロジ受け渡し、経路探索を行うクラス
    # @graph = Graph.new
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
    return if @hosts.key?(host[0])
    ## @hostsへのHostの格納
    h = Host.new(host[0], host[1], host[2], host[3])
    @hosts[host[0]] = h ## key=mac_addressで格納
    puts "add host: #{h.mac_address}"
    ## @topoへの追加
    add_switch2host_link(h)
    mac_address, _ip_address, dpid, port_no = *host
    maybe_send_handler :add_host, mac_address, Port.new(dpid, port_no), self
    # topo2json
  end

  private

  ## @topoをJSON形式で出力する
  ##
  def topo2json
    File.open("/tmp/topology.json", "w") do |file|
      JSON.dump(@topo, file)
    end
  end

  ## @topoにs2sのリンクを追加する関数
  ##
  def add_switch2switch_link(link)
    l = Hash.new { [].freeze }
    l.store(:type, "switch2switch")
    ## swtich_a,switch_b各々へdpidとport_noの格納
    l.store(:switch_a, {dpid: link.dpid_a, port_no: link.port_a})
    l.store(:switch_b, {dpid: link.dpid_b, port_no: link.port_b})
    @topo.push(l)
    # topo2json
  end

  ## @topoにs2hのリンクを追加する関数
  ##
  def add_switch2host_link(hostStats) ##hostStatsはHost型
    l = Hash.new { [].freeze }
    l.store(:type, "switch2host")
    ## Switch
    l.store(:switch_a, {dpid: hostStats.dpid, port_no: hostStats.port_no})
    ## Host
    l.store(:host, hostStats)
    @topo.push(l)
    # topo2json
  end

  ## @topoからs2s,s2hのリンクを削除する関数
  ##
  def delete_switch2switch_link(port)
    for each in @topo
      ## switch_aおよびbとdpid,portの組み合わせが一致した場合に@topoからリンクを削除
      if (each[:switch_a][:dpid] == port.dpid) && (each[:switch_a][:port_no] == port.number)
        ## s2hの場合は@hostsからホストを削除
        if (each[:type] == "switch2host")
          @hosts.delete(each[:host].mac_address)
          puts "delete_host: #{each[:host].mac_address} from dpid: #{each[:switch_a][:dpid]}"
        end
        @topo -= [each]
        # topo2json
      elsif (each[:type] == "switch2switch") && (each[:switch_b][:dpid] == port.dpid) && (each[:switch_b][:port_no] == port.number)
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
