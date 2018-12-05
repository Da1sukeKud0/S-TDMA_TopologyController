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
        # str[0] = str[0].to_i + 1
        # str[1] = str[1].to_i + 1
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
  ## 指定回数のスケジューリング探索の実行
  def add_rtcs(num)
    num = num.to_i
    ## 重複しないようにnum回分のsrc,dstをランダムに選択(periodは重複可)
    srcList = []
    dstList = []
    l = Array.new(@switchNum) { |index| index + 1 }
    popMax = @switchNum
    num.times do
      srcList.push(l.delete_at(rand(popMax)))
      popMax -= 1
      dstList.push(l.delete_at(rand(popMax)))
      popMax -= 1
    end
    ## num回分探索
    result = []
    for n in Range.new(1, num)
      src = srcList.pop
      dst = dstList.pop
      period = rand(4) + 2
      puts ""
      puts "add_rtc?(src: h#{src}, dst: h#{dst}, period: #{period})"
      # startwatch("add_rtc?呼び出し")
      st = Time.now
      tf = @rtcManager.add_rtc?(@hosts["mac" + src.to_s], @hosts["mac" + dst.to_s], period, @topo)
      puts time = (Time.now - st)
      # stopwatch("スケジューリング終了")

      ## 計測結果をresultに格納
      r = Hash.new
      # r.store("type", @type) ## トポロジタイプ
      # r.store("snum", @switchNum) ## スイッチ数
      # r.store("complexity", @complexity) ## 複雑度
      # r.store("rnum", num) ## RTC数
      r.store("lnum", @edges.size) ## リンク数
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

  ## タイマー
  def startwatch(tag)
    @timer = Time.now
    @old_tag = tag
  end

  ## 前回の呼び出しからの経過時間を測定
  def stopwatch(tag)
    if @timer
      puts ""
      puts "during time of #{@old_tag} to #{tag}: #{Time.now - @timer}"
      puts ""
    end
  end
end

def sh(command)
  system(command) || fail("#{command} failed.")
  @logger.debug(command) if @logger
end

def output_json(file_name, hash)
  File.open(file_name, "a") do |file|
    JSON.dump(hash, file)
  end
end

if __FILE__ == $0
  if (ARGV[0].nil? || ARGV[1].nil?)
    puts "usage: ruby rtc_manager_test.rb switchNum complexity rtcNum"
    puts "use default parameter: switchNum = 30, complexity = 2, rtcNum = 3"
    ARGV[0] = 30
    ARGV[1] = 2
    ARGV[2] = 3
  end

  output = []
  50.times do
    rmt = RTCManagerTest.new
    rmt.make_ba_topology(ARGV[0], ARGV[1])
    res = rmt.add_rtcs(ARGV[2])
    puts res
    output.push(res)
  end
  file_name = "BA_s#{ARGV[0]}_cplx#{ARGV[1]}_rtc#{ARGV[3]}"
  output_json(file_name, output)
end
