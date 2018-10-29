## 実時間通信タスク
## 送信元/宛先idおよび通信周期は初期入力
## スケジューリング可能であれば通信経路とタイムスロットIDを獲得
class RTC
  attr_reader :route
  attr_reader :timeslot_id

  def initialize(src_id, dst_id, period)
    @src_id = src_id ## dpidの予定
    @dst_id = dst_id ## dpidの予定
    @period = period ## 通信周期（タイムスロット単位）
    @schedule = nil ## スケジューリング可能な場合にsetScheduleで格納
  end

  ## 通信経路とタイムスロットIDの格納
  def setSchedule(timeslot_id, route)
    @schedule = Hash.new { [].freeze }
    @schedule.store(:timeslot_id, timeslot_id)
    @schedule.store(:route, route)
  end

  ## 通信経路とタイムスロットIDの取得
  def getSchedule
    unless @schedule.nil?
      puts @schedule
    end
  end

  ## スケジューリングの可否を確認
  def schedulable?
    return !@schedule.nil?
  end
end

def test
  rtc = RTC.new(1, 2, 3)
  # rtc.setSchedule(4, 5)
  rtc.getSchedule
  puts rtc.schedulable?
end
