require "~/trema/topology/lib/RTC"
require "~/trema/topology/lib/dijkstra"
##
##　実時間通信要求に対し経路スケジューリングおよび時刻スケジューリングを行う
##

class RTCManager
  def initialize
    @map = Dijkstra.new ## 経路計算アルゴリズム用に変換されたトポロジ情報
    @hst_table = Hash.new ## ホストの識別名(h1,h2,,,hn)とmac_addressの対応
    @rtcList = [] ## 実時間通信タスク
  end

  attr_reader :map
  attr_reader :mac_table

  ## 実時間通信要求に対しスケジューリング可否を判定
  ## 可能ならrtcListを更新しtrue 不可ならfalse
  def add_rtc?(src, dst, period, topo)
    rtc = RTC.new(src, dst, period)
    routeSchedule(rtc, topo)
    periodSchedule(rtc)
    if rtc.schedulable? ## スケジューリング可能
      @rtcList.push(rtc)
      return true
    else ## スケジューリング不可
      return false
    end
  end

  private

  ## 経路スケジューリング：既存の実時間通信との非重複経路を探索
  ## 可能ならrtc.scheduleに経路とタイムスロットIDを追加する
  def routeSchedule(rtc, topo)
    setGraph(topo)
    if (@rtcList.size == 0)
      @map.shortest_path(@hst_table.invert(rtc.src), @hst_table.invert(rtc.dst))
    else
      @rtcList.each do |each|
      end
    end
  end

  def setGraph(topo)
    for each in topo
      if (each[:type] == "switch2host")
        ## s2hリンクの場合
        hst_id = "h" + (@mac_table.size + 1).to_s
        @hst_table[hst_id] = each[:host]
        @map.add_edge(each[:switch_a].dpid, hst_id)
        puts "#{each[:switch_a].dpid} to #{hst_id} link add"
      else
        ## s2sリンクの場合
        @map.add_edge(each[:switch_a].dpid, each[:switch_b].dpid) ## all cost is 1
        puts "#{each[:switch_a].dpid} to #{each[:switch_b].dpid} link add"
      end
    end
  end

  ## 時刻スケジューリング：他の実時間通信の周期と被らないように新規タイムスロットを設定
  def periodSchedule(rtc)
    
  end
end

## memo
## とりあえずsend_packetsで特定のホストへの接続要求を行う
