require "rational"

def test1
  @rtc_timeslot = Hash.new

  @rtc_timeslot["slot"] = []
  @rtc_timeslot["slot"].push("rtc")
  @rtc_timeslot["slot"].push("rtc")

  @rtc_timeslot.each do |key, value|
    puts value
  end
end

def test2
  puts "test"
  @array = Hash.new { |hash, key| hash[key] = [] }
  # @array[9].push("rtc")
  puts @array.all? { |key, each| each.size == 0 }
  # puts "   push  "
  # @array[9].push("rtc")
  # puts @array.all? { |key, each| each.size == 0 }
  # puts "   delete"
  # @array[9].delete("rtc")
  # puts @array[9].size
  # puts @array.all? { |key, each| each.size == 0 }
  # # @array.each do |key, val|
  # #   puts "key=#{key}, valsize=#{val.size}"
  # # end
  puts "test2"
  initial_phase = 1
  period = 2
  for i in Range.new(0, 9)
    if ((i + initial_phase) % period == 0)
      @array[i].push("rtc")
      @array[i].push("rtc2")
      puts i
    end
  end
  @array.each do |key, value|
    puts "key=#{key}, value=#{value}"
  end
end

def test3
  puts "test3"
  @arr = Hash.new
  for i in Range.new(0, 9)
    @arr[i] = []
  end
  puts @arr
  puts @arr.all? { |key, each| each.size == 0 }
  @arr[3].push("test")
  @arr.each do |key, vals|
    puts key
    vals.each do |val|
      puts "key=#{key},vals=#{vals.size}"
    end
  end
end

def test4
  puts "test4"
  @hst_table = Hash.new
  puts @hst_table.size
end

def test5
  list = Hash.new { |hash, key| hash[key] = [] }
  list[1].push("p1")
  @period_list = []
end

h = { "def" => 2, "ghi" => 1, "abc" => 3 }
p h.sort.to_h
p "h is #{h}"
p h.sort.reverse.to_h
p "h is #{h}"
p h.sort_by{ | k, v | v }.to_h
p "h is #{h}"
p h.sort{ | a, b | b[1] <=> a[1] }.to_h
p "h is #{h}"
