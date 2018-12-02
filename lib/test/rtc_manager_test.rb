require_relative "../rtc_manager"
require_relative "../host"
require "networkx"
require "open3"
require "json"

class RTCManagerTest
  def initialize
    @rtcManager = RTCManager.new
    @topo = []
    @hosts = Hash.new { [].freeze } ## hosts{}: keyはホストのmac_address

    edges = []
    switchNum = ARGV[0].to_i
    sh ("python ~/trema/topology/lib/test/barabasi_albert_graph.py #{switchNum} #{ARGV[1]}")
    File.open(".edges") do |file|
      file.each_line do |l|
        str = l[1..l.size - 3].split(", ")
        str[0] = str[0].to_i + 1
        str[1] = str[1].to_i + 1
        edges.push(str)
      end
    end
    edges.each do |src, dst|
      puts "src: #{src}, dst: #{dst}"
      add_switch2switch_link(src, dst)
    end
    for i in Range.new(1, switchNum)
      # mac_address = [0x52, 0x42, 0x00, Random.rand(0x7f), Random.rand(0xff), Random.rand(0xff)]
      mac_address = "mac" + i.to_s
      maybe_add_host(mac_address, i)
    end
    @rtcManager.add_rtc?(@hosts["mac1"], @hosts["mac6"], 5, @topo)
    # @rtcManager.add_rtc?(2, 13, 2, @topo)
    # @rtcManager.add_rtc?(16, 8, 2, @topo)
  end

  def create_new_topology(switchNum, complexity)
  end

  def maybe_add_host(mac_address, dpid)
    ## @hostsへのHostの格納
    h = Host.new(mac_address, "ip_address", dpid, "s" + dpid.to_s + "ph")
    @hosts[mac_address] = h ## key=mac_addressで格納
    # puts "add host: #{h.mac_address}"
    ## @topoへの追加
    add_switch2host_link(h)
  end

  ## @topoにs2sのリンクを追加する関数
  ##
  def add_switch2switch_link(dpid_a, dpid_b)
    l = Hash.new { [].freeze }
    l.store(:type, "switch2switch")
    ## swtich_a,switch_b各々へdpidとport_noの格納
    l.store(:switch_a, {dpid: dpid_a, port_no: "s" + dpid_a.to_s + "to" + dpid_b.to_s})
    l.store(:switch_b, {dpid: dpid_b, port_no: "s" + dpid_b.to_s + "to" + dpid_a.to_s})
    @topo.push(l)
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
  end
end

def sh(command)
  system(command) || fail("#{command} failed.")
  @logger.debug(command) if @logger
end

if __FILE__ == $0
  rtcManagerTest = RTCManagerTest.new
end
