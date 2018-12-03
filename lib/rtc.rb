## 実時間通信タスク
## 送信元/宛先idおよび通信周期は初期入力
## スケジューリング可能であれば通信経路とタイムスロットIDを獲得
class RTC
  def initialize(src, dst, period)
    @src = src ## Host型の予定
    @dst = dst ## Host型の予定
    @period = period ## 通信周期（タイムスロット単位）
  end

  attr_reader :src
  attr_reader :dst
  attr_reader :period
  attr_reader :initial_phase
  attr_reader :route

  ## 通信経路とタイムスロットIDの格納
  def setSchedule(initial_phase, route)
    @initial_phase = initial_phase
    @route = route
    # puts "ip= #{initial_phase}, route= #{route}"
    puts "route= #{route}"
    return self
  end
end

def test
  rtc = RTC.new(1, 2, 3)
  # rtc.setSchedule(4, 5)
  rtc.getSchedule
  puts rtc.schedulable?
end
