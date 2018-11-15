##
## ネットワーク全体でのスケジュール管理を行うクラス
##
class NetworkScheduler < Trema::Controller

  def initialize
    @schedule_table = Hash.new
    for i in Range.new(0, 9)
      @schedule_table[i] = []
    end
  end

  def make_flowmods(flowmod_list)
    flowmod_list.each do |each|
      send_flow_mod_add(
        each[:dpid],
        match: Match.new(in_port: each[:in_port]),
        actions: SendOutPort.new(each[:out_port]),
      )
    end
  end
end
