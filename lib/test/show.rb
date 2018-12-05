require "json"

File.open("BA_s30_cplx2_rtc3.json", "r") do |f|
  hash = JSON.load(f)
  puts hash
  t1 = []
  t2 = []
  t3 = []
  hash.each do |each|
    if (each["turn"] == 1)
      t1.push(each["time"])
    elsif (each["turn"] == 2)
      t2.push(each["time"])
    else
      t3.push(each["time"])
    end
  end
  puts t1.inject(0.0){|r,i| r+=i }/t1.size
  puts t2.inject(0.0){|r,i| r+=i }/t2.size
  puts t3.inject(0.0){|r,i| r+=i }/t3.size
end
