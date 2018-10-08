require 'json'

File.open("/tmp/topology.json") do |file|
  hash = JSON.load(file)
  h= JSON.pretty_generate(hash)
  puts h
end
