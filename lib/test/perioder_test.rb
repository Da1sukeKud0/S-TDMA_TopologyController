## RTCManager内でのrtcの周期関連の処理をテストするためのスクリプト
## 
class Perioder
  attr_reader :lcm

  def initialize
    list = Hash.new { |hash, key| hash[key] = [] }
    @period_list = []
  end

  def add_period(period)
    @period_list.push(period)
    puts "plist is #{@period_list}"
    if (@period_list.size == 1)
      @lcm = period
      puts "lcm is #{@lcm}"
    else
      old_lcm = @lcm
      res = calc_lcm / old_lcm
      puts "#{res} bai !"
    end
    return res
  end

  ## routeSchedule
  ## @period_listに新規periodを追加する関数
  def add_period(period)
    @period_list.push(period)
    puts "plist is #{@period_list}"
    if (@period_list.size == 1)
      @lcm = period
      # puts "lcm is #{@lcm}"
      return 1
    else
      old_lcm = @lcm
      res = calc_lcm / old_lcm
      # puts "#{res} bai !"
      return res
    end
  end

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

  private

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
end

p = Perioder.new
p.add_period(2)
puts "add_period?"
p.add_period?(2)
puts ""
p.add_period(3)
puts ""
p.add_period(4)
puts ""
p.add_period(2)
puts ""

p.del_period(2)
puts ""
p.del_period(3)
puts ""
p.del_period(2)
puts ""
p.del_period(4)
puts ""
