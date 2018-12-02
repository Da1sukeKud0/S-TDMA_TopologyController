require_relative "rtc"
require_relative "dijkstra"
require "rational"
##
##　実時間通信要求に対し経路スケジューリングおよび時刻スケジューリングを行う
##

class RTCManager
  def initialize
    @hst_table = Hash.new ## {h1(ホスト識別名)=>mac_address, ,,}
    @timeslot_table = Hash.new { |hash, key| hash[key] = [] } ## {timeslot=>[rtc,rtc,,,], ,,}
    @period_list = [] ## 周期の種類を格納(同じ数値の周期も重複して格納)
    # @networkscheduler = NetworkScheduler.new ## beta
  end

  attr_reader :map
  attr_reader :mac_table

  ## 実時間通信要求に対しスケジューリング可否を判定
  ## 可能ならrtcListを更新しtrue 不可ならfalse
  def add_rtc?(src, dst, period, topo)
    puts topo
    rtc = RTC.new(src, dst, period)
    initial_phase = 0 ##初期位相0に設定
    ## 0~periodの間でスケジューリング可能な初期位相を探す
    while (initial_phase < period)
      if (routeSchedule(rtc, topo, initial_phase)) ##スケジューリング可
        puts @timeslot_table
        # test(@timeslot_table, topo)
        return true
      else ##スケジューリング不可
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

  ##　得られたtimeslot_tableを
  ## flowModに必要なdpid, in_port(match), out_port(action)の情報に変換する関数
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
    # @networkscheduler.make_flowmods(flowmod_list)
    # end
  end

  private

  ## add_rtc
  ## 既存の実時間通信との非重複経路を探索
  ## 存在する場合はrtcにroute, initial_phaseを追加しtrue
  ## 存在しない場合は初期位相を変化させ再帰呼出し
  ## それでも非重複経路が存在しない場合はfalse
  def routeSchedule(rtc, topo, initial_phase)
    if (@timeslot_table.all? { |key, each| each.size == 0 }) ##既存のrtcがない場合
      map = setGraph(topo)
      route = map.shortest_path(@hst_table.key(rtc.src), @hst_table.key(rtc.dst))
      if (route) ##経路が存在する場合は使用するスロットにrtcを格納
        rtc.setSchedule(initial_phase, route)
        # for i in Range.new(initial_phase, @timeslot_table.size - 1)
        #   if ((i + initial_phase) % rtc.period == 0)
        #     @timeslot_table[i].push(rtc)
        #   end
        # end
        for i in Range.new(0, rtc.period - 1)
          if ((i + initial_phase) % rtc.period == 0)
            @timeslot_table[i].push(rtc)
          else
            @timeslot_table[i] = []
          end
        end
        add_period(rtc.period)
      else ##ルートなし
        return false
      end
    else ## 既存のrtcがある場合
      puts "old_lcm is #{@lcm}"
      ## 計算用のtmp_timeslot_tableに@timeslot_tableを複製(倍率はadd_period?に従う)
      tmp_timeslot_table = Hash.new { |hash, key| hash[key] = [] }
      @timeslot_table.each do |timeslot, exist_rtcs|
        for i in Range.new(0, add_period?(rtc.period) - 1)
          tmp_timeslot_table[timeslot + @lcm * i] = @timeslot_table[timeslot].clone
        end
      end
      puts "@timeslot_table"
      puts @timeslot_table
      puts "tmp_timeslot_table"
      puts tmp_timeslot_table
      route_list = Hash.new() ## 一時的な経路情報格納 {timeslot=>route,,,}
      tmp_timeslot_table.each do |timeslot, exist_rtcs|
        ## initial_phase = 0として、timeslotが被るrtcがあれば抽出し使用ルートを削除してから探索
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
          else ## 最終的に無理
            return false
          end
        end
      end
      ## ここでfalseでない時点で0~9のうち使用する全てのタイムスロットでルーティングが可能
      ## まずtmp_timeslot_tableを複製
      @timeslot_table = tmp_timeslot_table.clone
      ## period_listの更新
      add_period(rtc.period)
      ## @timeslot_tableに対しroute_listに従ってrtcを追加
      route_list.each do |key, val|
        rtc.setSchedule(initial_phase, val)
        @timeslot_table[key].push(rtc.clone)
      end
      @timeslot_table = @timeslot_table.sort.to_h
    end
    return true
  end

  ## routeSchedule
  ## @topoの形式を変換しDijkstraクラスのインスタンスを返す関数
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
        # puts "#{each[:switch_a][:dpid]} to #{hst_id} link add"
      else
        ## s2sリンクの場合
        map.add_edge(each[:switch_a][:dpid], each[:switch_b][:dpid]) ## cost 1
        # puts "#{each[:switch_a][:dpid]} to #{each[:switch_b][:dpid]} link add"
      end
    end
    puts "nodes = #{map.nodes}"
    return map
  end

  ## routeSchedule
  ## @period_listに新規periodを追加する関数
  def add_period(period)
    @period_list.push(period)
    puts "plist is #{@period_list}"
    if (@period_list.size == 1)
      @lcm = period
      return 1
    else
      old_lcm = @lcm
      res = calc_lcm / old_lcm
      return res
    end
  end

  ## routeSchedule
  ## @period_listに新規periodを追加した場合の
  ## @timeslot_tableの倍率を返す関数
  def add_period?(period)
    puts "plist is #{@period_list}"
    if (@period_list.size == 0)
      @lcm = period
      puts "lcm is #{@lcm}"
      return 1
    else
      old_lcm = @lcm
      res = (@lcm.lcm(period)) / old_lcm
      puts "#{res} bai !"
    end
    return res
  end

  ## routeSchedule
  ## @period_listから指定したperiodを1つだけ削除する関数
  def del_period(period)
    for i in Range.new(0, @period_list.size - 1)
      if (@period_list[i] == period)
        @period_list.delete_at(i)
        break
      end
    end
    puts "plist is #{@period_list}"
    if (@period_list.size == 0)
      @lcm = 0
      puts "timeslot all delete"
    else
      old_lcm = @lcm
      puts "minus #{old_lcm / calc_lcm} bai !"
    end
  end

  ## add_period, del_period
  ## @period_listの要素全ての最小公倍数を返す関数
  def calc_lcm
    if @period_list.size == 0
      puts "0"
      return 0
    elsif (@period_list.size == 1)
      puts @period_list[0]
      return @period_list[0]
    else
      @lcm = 1
      for i in Range.new(0, @period_list.size - 1)
        @lcm = @lcm.lcm(@period_list[i])
      end
      puts "lcm is #{@lcm}"
      return @lcm
    end
  end

  ## test
  ## src_dpidとdst_dpid間のリンクを検索し
  ## src_dpid側のポート番号を返す関数
  def toposearch(src_dpid, dst_dpid, topo)
    for each in topo
      if (each[:type] == "switch2switch")
        if (each[:switch_a][:dpid] == src_dpid) && (each[:switch_b][:dpid] == dst_dpid)
          return each[:switch_a][:port_no]
        elsif (each[:switch_b][:dpid] == src_dpid) && (each[:switch_a][:dpid] == dst_dpid)
          return each[:switch_b][:port_no]
        end
      end
    end
  end
end
