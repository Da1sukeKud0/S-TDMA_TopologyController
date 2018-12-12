require_relative "../rtc_manager"
require_relative "../host"
require "json"

class RTCManagerTest
  def initialize()
    @rtcManager = RTCManager.new
    @topo = []
    @hosts = Hash.new { [].freeze } ## {mac_address=>Host,,,}
    @edges = []
  end

  ## main
  ## BAモデルに基づいたトポロジの生成
  def make_ba_topology(switchNum, complexity)
    @type = "BA"
    @switchNum = switchNum.to_i
    @complexity = complexity.to_i
    ## barabasi_albert_graph.pyを外部実行
    sh ("python ~/trema/topology/lib/test/barabasi_albert_graph.py #{@switchNum} #{@complexity}")
    ## 生成されたリンクを@edgesに格納
    File.open(".edges") do |file|
      file.each_line do |l|
        str = l[1..l.size - 3].split(", ")
        @edges.push(str)
      end
    end
    ## @edgesからs2sリンクを生成
    @edges.each do |src, dst|
      # puts "src: #{src}, dst: #{dst}"
      add_switch2switch_link(src, dst)
    end
    ## switchNum個のホストを同番のスイッチに接続
    make_host()
  end

  ## main
  ## ツリートポロジを生成
  def make_tree_topology(depth, fanout)
    @type = "tree"
    @depth = depth.to_i
    @fanout = fanout.to_i
    node = 1
    papa = [], child = [1]
    ## ホストまで含めたツリーの深さなので@depth - 1でループ
    (@depth - 1).times do
      papa = child
      child = []
      ## 親ノードに@fanout個の子ノードを接続
      for p in papa
        @fanout.times do
          node += 1
          @edges.push([p, node])
          # puts "add link: #{p} to #{node}"
          add_switch2switch_link(p, node)
          child.push(node)
        end
      end
    end
    @switchNum = node
    ## 最も若いノードにそれぞれfanout個のホストを付加
    hnode = 0
    for c in child
      @fanout.times do
        hnode += 1
        mac_address = "mac" + hnode.to_s
        maybe_add_host(mac_address, c)
        # puts "add link: #{c} to host#{hnode.to_s}"
      end
    end
  end

  ## main
  ## フルメッシュトポロジを生成
  def make_fullmesh_topology(switchNum)
    @type = "fullmesh"
    @switchNum = switchNum.to_i
    for src in Range.new(1, @switchNum)
      for dst in Range.new(1, @switchNum)
        next if (src == dst)
        puts "add link: #{src} to #{dst}"
        add_switch2switch_link(src, dst)
      end
      mac_address = "mac" + src.to_s
      maybe_add_host(mac_address, src)
    end
  end

  ## main
  ## 指定回数のスケジューリング探索の実行
  def add_rtcs(num)
    num = num.to_i
    ## 重複しないようにnum回分のsrc,dstをランダムに選択(periodは重複可)
    srcList = []
    dstList = []
    l = Array.new(@hosts.size) { |index| index + 1 }
    popMax = @hosts.size
    num.times do
      srcList.push(l.delete_at(rand(popMax)))
      popMax -= 1
      dstList.push(l.delete_at(rand(popMax)))
      popMax -= 1
    end

    ## num回分探索の準備
    result = [] ## num回分の探索結果を格納 [r, r, ... , r]
    tagList = Hash.new ## データのタグリスト(rtcの実行順(turn)を除く)
    tagList.store("type", @type) ## トポロジタイプ
    tagList.store("snum", @switchNum) ## スイッチ数
    tagList.store("rnum", num) ## RTC数
    tagList.store("lnum", @edges.size) ## リンク数(switchNum-complexity)*complexityで算出可能
    if (@type == "BA")
      tagList.store("cplx", @complexity) ## 複雑度
    elsif (@type == "tree")
      tagList.store("dep", @depth)
      tagList.store("fan", @fanout)
    end

    ## num回分探索
    for n in Range.new(1, num)
      src = srcList.pop
      dst = dstList.pop
      period = rand(4) + 2
      puts ""
      puts "add_rtc?(src: h#{src}, dst: h#{dst}, period: #{period})"
      # 以下でスケジューリング処理の時間を計測
      st = Time.now
      tf = @rtcManager.add_rtc?(@hosts["mac" + src.to_s], @hosts["mac" + dst.to_s], period, @topo)
      puts time = (Time.now - st)
      ## 計測結果をresultに格納
      r = tagList.clone
      r.store("turn", n) ## RTC実行順
      r.store("time", time) ## 処理時間
      r.store("tf", tf) ## add_rtc?
      result.push(r)
    end
    return result
  end

  private

  def make_host()
    for i in Range.new(1, @switchNum)
      # mac_address = [0x52, 0x42, 0x00, Random.rand(0x7f), Random.rand(0xff), Random.rand(0xff)]
      mac_address = "mac" + i.to_s
      maybe_add_host(mac_address, i)
    end
  end

  def maybe_add_host(mac_address, dpid)
    ## @hostsへのHostの格納
    h = Host.new(mac_address, "ip_address", dpid, "s" + dpid.to_s + "ph")
    @hosts[mac_address] = h ## key=mac_addressで格納
    # puts "add host: #{h.mac_address}"
    ## @topoへの追加
    add_switch2host_link(h)
  end

  ## @topoにs2hのリンクを追加する関数
  def add_switch2host_link(hostStats) ##hostStatsはHost型
    l = Hash.new { [].freeze }
    l.store(:type, "switch2host")
    ## Switch
    l.store(:switch_a, {dpid: hostStats.dpid, port_no: hostStats.port_no})
    ## Host
    l.store(:host, hostStats)
    @topo.push(l)
  end

  ## @topoにs2sのリンクを追加する関数
  def add_switch2switch_link(dpid_a, dpid_b)
    l = Hash.new { [].freeze }
    l.store(:type, "switch2switch")
    ## swtich_a,switch_b各々へdpidとport_noの格納
    l.store(:switch_a, {dpid: dpid_a, port_no: "s" + dpid_a.to_s + "to" + dpid_b.to_s})
    l.store(:switch_b, {dpid: dpid_b, port_no: "s" + dpid_b.to_s + "to" + dpid_a.to_s})
    @topo.push(l)
  end
end

def sh(command)
  system(command) || fail("#{command} failed.")
  @logger.debug(command) if @logger
end

def output_json(file_name, hash)
  File.open(file_name, "w") do |file|
    JSON.dump(hash, file)
  end
end

## 端末から各種パラメータを指定して実行
def test_arg_from_console()
  if (ARGV[0].nil? || ARGV[1].nil?)
    puts "usage: ruby rtc_manager_test.rb switchNum complexity rtcNum"
    puts "use default parameter: switchNum = 30, complexity = 2, rtcNum = 3"
    ARGV[0] = 30
    ARGV[1] = 2
    ARGV[2] = 3
  end
  output = []
  20.times do
    rmt = RTCManagerTest.new
    rmt.make_ba_topology(ARGV[0], ARGV[1])
    res = rmt.add_rtcs(ARGV[2])
    puts res
    res.each do |each|
      output.push(each)
    end
  end
  file_name = "BA_s#{ARGV[0]}_cplx#{ARGV[1]}_rtc#{ARGV[2]}.json"
  output_json(file_name, output)
end

## BAモデルでの各種パラメータを自動設定し実行
def test_BA_loop()
  output = []
  snum = 60
  9.times do
    cplx = 1
    5.times do
      30.times do
        rmt = RTCManagerTest.new
        rmt.make_ba_topology(snum, cplx)
        res = rmt.add_rtcs(5)
        puts res
        res.each do |each|
          output.push(each)
        end
      end
      cplx += 1
    end
    snum += 5
  end
  file_name = "rtcm_test_20181210_2.json"
  output_json(file_name, output)
end

## BAモデルに基づくランダムトポロジでの各種パラメータを設定し実行
def test_BA()
  # output = []
  rmt = RTCManagerTest.new
  rmt.make_ba_topology(30, 2)
  res = rmt.add_rtcs(5)
  puts res
  # file_name = "rtcm_test_20181210_2.json"
  # output_json(file_name, output)
end

## ツリートポロジでの各種パラメータを設定し実行
def test_tree()
  # output = []
  rmt = RTCManagerTest.new
  rmt.make_tree_topology(4, 3)
  res = rmt.add_rtcs(3)
  puts res
  # file_name = "rtcm_test_20181210_2.json"
  # output_json(file_name, output)
end

## フルメッシュトポロジでの各種パラメータを設定し実行
def test_fullmesh()
  # output = []
  rmt = RTCManagerTest.new
  rmt.make_fullmesh_topology(6)
  res = rmt.add_rtcs(3)
  puts res
  # file_name = "rtcm_test_20181210_2.json"
  # output_json(file_name, output)
end

if __FILE__ == $0
  test_tree()
end
