@rtc_timeslot = Hash.new

@rtc_timeslot["slot"] = []
@rtc_timeslot["slot"].push("rtc")
@rtc_timeslot["slot"].push("rtc")

@rtc_timeslot.each do |key, value|
  puts value
end

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

puts "test4"
@hst_table = Hash.new
puts @hst_table.size