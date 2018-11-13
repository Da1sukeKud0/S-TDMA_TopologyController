require "~/trema/topology/lib/rtc"
require "~/trema/topology/lib/dijkstra"
##
##　実時間通信要求に対し経路スケジューリングおよび時刻スケジューリングを行う
##

class RTCManager
  def initialize
    @hst_table = Hash.new ## ホストの識別名(h1,h2,,,hn)とmac_addressの対応
    @timeslot_table = Hash.new ##timeslot_id: [rtc,rtc,,,]
    for i in Range.new(0, 9)
      @timeslot_table[i] = []
    end
  end

  attr_reader :map
  attr_reader :mac_table

  ## 実時間通信要求に対しスケジューリング可否を判定
  ## 可能ならrtcListを更新しtrue 不可ならfalse
  def add_rtc?(src, dst, period, topo)
    rtc = RTC.new(src, dst, period)
    initial_phase = 0 ##初期位相0に設定
    while (initial_phase < period)
      if (routeSchedule(rtc, topo, initial_phase))
        puts @timeslot_table
        test(@timeslot_table, topo)
        return true
      else
        initial_phase += 1
      end
    end
    puts "####################"
    puts "####################"
    puts "####### false ######"
    puts "####################"
    puts "####################"
    return false
  end

  def toposearch(src_dpid, dst_dpid, topo)
    ##topoから接続先を検索##
    for each in topo
      if (each[:type] == "switch2switch")
        if (each[:switch_a][:dpid] == src_dpid) && (each[:switch_b][:dpid] == dst_dpid)
          return each[:switch_a][:port_no]
        elsif (each[:switch_b][:dpid] == src_dpid) && (each[:switch_a][:dpid] == dst_dpid)
          return each[:switch_b][:port_no]
        end
      end
    end
    ##topoから接続先を検索##
  end

  def test(timeslot_table, topo)
    flowmod_list = []
    # timeslot_table.each do |key, value|
    for rtc in timeslot_table[0]
      fm = Hash.new
      fm.store(:dpid, rtc.src.dpid)
      fm.store(:in_port, rtc.src.port_no)
      fm.store(:out_port, toposearch(rtc.route[1][:src].to_i, rtc.route[1][:dst].to_i, topo))
      flowmod_list.push(fm)
      range = rtc.route.size
      for i in Range.new(1, range - 3)
        fm = Hash.new
        fm.store(:dpid, rtc.route[i][:dst].to_i)
        fm.store(:in_port, toposearch(rtc.route[i][:dst].to_i, rtc.route[i][:src].to_i, topo))
        fm.store(:out_port, toposearch(rtc.route[i + 1][:src].to_i, rtc.route[i + 1][:dst].to_i, topo))
        flowmod_list.push(fm)
      end
      fm = Hash.new
      fm.store(:dpid, rtc.dst.dpid)
      fm.store(:in_port, toposearch(rtc.route[range - 2][:dst].to_i, rtc.route[range - 2][:src].to_i, topo))
      fm.store(:out_port, rtc.dst.port_no)
      flowmod_list.push(fm)
    end
    puts flowmod_list
    # end
  end

  private

  ## 既存の実時間通信との非重複経路を探索
  ## 存在する場合はrtcにroute, initial_phaseを追加しtrue
  ## 存在しない場合は初期位相を変化させ再帰呼出し
  ## それでも非重複経路が存在しない場合はfalse
  def routeSchedule(rtc, topo, initial_phase)
    if (@timeslot_table.all? { |key, each| each.size == 0 }) ##既存のrtcがない場合
      map = setGraph(topo)
      route = map.shortest_path(@hst_table.key(rtc.src), @hst_table.key(rtc.dst))
      if (route) ##経路が存在する場合は使用するスロットにrtcを格納
        # rtc_tmp = RTC.new(rtc.src, rtc.dst, rtc.period)
        # rtc_tmp.setSchedule(initial_phase, val)
        rtc.setSchedule(initial_phase, route)
        for i in Range.new(initial_phase, 9)
          if ((i + initial_phase) % rtc.period == 0)
            @timeslot_table[i].push(rtc)
          end
        end
      else ##ルートなし
        return false
      end
    else ## 既存のrtcがある場合
      route_list = Hash.new()
      @timeslot_table.each do |timeslot, exist_rtcs|
        ## initial_phase==0として、timeslotが被るrtcがあれば抽出し使用ルートを削除してから探索
        puts "tsl=#{timeslot}"
        if ((timeslot - initial_phase) % rtc.period == 0)
          map_tmp = setGraph(topo)
          if (exist_rtcs.size != 0) ## 同一タイムスロット内にrtcが既存
            puts "既存のRTCあるよ"
            for each_rtc in exist_rtcs
              puts "each_rtc=#{each_rtc}"
              for e in each_rtc.route
                map_tmp.delete_edge(e[:src], e[:dst])
              end
            end
          end
          ## 既存の使用ルートを除いてから再計算
          route = map_tmp.shortest_path(@hst_table.key(rtc.src), @hst_table.key(rtc.dst))
          if (route) ## ルーティング可能なら一時変数に格納
            route_list[timeslot] = route
          else ## ルーティング不可なら初期位相を変化させ再探索
            # if (initial_phase == 0)
            #   while (initial_phase < rtc.period)
            #     initial_phase += 1
            #     puts "再探索 初期位相は#{initial_phase}"
            #     if (routeSchedule(rtc, topo, initial_phase))
            #       return true
            #     end
            #     break if ((initial_phase - 1)==rtc.period)
            #   end
            # end
            return false
          end
        end
      end
      ## ここでfalseでない時点で0~9のうち使用する全てのタイムスロットでルーティングが可能
      route_list.each do |key, val|
        rtc_tmp = RTC.new(rtc.src, rtc.dst, rtc.period)
        rtc_tmp.setSchedule(initial_phase, val)
        @timeslot_table[key].push(rtc_tmp)
      end
    end
    return true
  end

  def setGraph(topo)
    map = Dijkstra.new ## 経路計算アルゴリズム用に変換されたトポロジ情報
    for each in topo
      if (each[:type] == "switch2host")
        ## s2hリンクの場合
        if @hst_table.value?(each[:host])
          hst_id = @hst_table.key(each[:host])
        else
          hst_id = "h" + (@hst_table.size + 1).to_s
          @hst_table[hst_id] = each[:host]
        end
        map.add_edge(each[:switch_a][:dpid], hst_id, 0) ## cost 0
        puts "#{each[:switch_a][:dpid]} to #{hst_id} link add"
      else
        ## s2sリンクの場合
        map.add_edge(each[:switch_a][:dpid], each[:switch_b][:dpid]) ## cost 1
        puts "#{each[:switch_a][:dpid]} to #{each[:switch_b][:dpid]} link add"
      end
    end
    return map
  end
end

## memo
## とりあえずsend_packetsで特定のホストへの接続要求を行う
