##
##　実時間通信要求に対し経路スケジューリングおよび時刻スケジューリングを行う
##
require "RTC"

class RTCManager
  def initialize
    @rtcList = [] ## 実時間通信タスク
  end

  ## 実時間通信要求に対しスケジューリング可否を判定
  ## 可能ならrtcListを更新しtrue 不可ならfalse
  def addRTC?(src_id, dst_id, period, topo)
    rtc = RTC.new(src_id, dst_id, period)
    routeSchedule(rtc)
    periodSchedule(rtc)
    if rtc.schedulable?
      @rtcList.push(rtc)
      return true
    else
      return false
    end
  end

  private

  ## 経路スケジューリング
  ## timeslot_idごとに非重複経路を探索
  def routeSchedule(rtc)
  end

  ## 時刻スケジューリング
  ## 他のRTCの周期と被らないように新規タイムスロットを設定
  def periodSchedule(rtc)
  end
end
