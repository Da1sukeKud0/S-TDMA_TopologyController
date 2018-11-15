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
    elsif old_lcm = @lcm
      puts "#{calc_lcm / old_lcm} bai !"
    end
  end

  def del_period(period)
    # @period_list.delete(period)
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
    elsif old_lcm = @lcm
      puts "minus #{old_lcm / calc_lcm} bai !"
    end
  end

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
