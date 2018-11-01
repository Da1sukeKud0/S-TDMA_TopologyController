require "~/trema/topology/lib/dijkstra"

## test
## native source code test
##
def test_native
  g = Dijkstra.new
  g.add_edge(1, 2, 5)
  g.add_edge(1, 3, 4)
  g.add_edge(1, 4, 2)
  g.add_edge(2, 3, 2)
  g.add_edge(2, 5, 6)
  g.add_edge(3, 4, 3)
  g.add_edge(3, 6, 2)
  g.add_edge(4, 6, 6)
  g.add_edge(5, 6, 4)
  # g.add_edge(1, 2)
  # g.add_edge(1, 3)
  # g.add_edge(1, 4)
  # g.add_edge(2, 3)
  # g.add_edge(2, 5)
  # g.add_edge(3, 4)
  # g.add_edge(3, 6)
  # g.add_edge(4, 6)
  # g.add_edge(5, 6)
  g.shortest_path(1, 5) ## {"src"=>"1", "dst"=>"5", "path"=>["1", "3", "6", "5"], "cost"=>10}
  g.shortest_path(1, 7) ## such node is not exist.
end

## test
## JSON test
##
def test
  def getJSON
    File.open("/share/home/kudo/trema/topology/test/topology.json") do |file|
      return JSON.load(file)
    end
  end

  topo = getJSON
  puts "-- topology --"
  puts topo
  puts ""

  puts "-- hostname => mac_address --"
  g = Dijkstra.new
  mac_table = Hash.new
  cost = [2, 3, 4, 6, 6, 5, 2, 2, 4] ## for test
  for each in topo
    if (each["type"] == "switch2host") ## s2h
      mac_table["h" + (mac_table.size + 1).to_s] = {"id_a" => each["id_a"], "mac_address" => each["id_b"]}
    else ## s2s
      g.add_edge(each["id_a"], each["id_b"], cost.shift)
    end
  end
  puts mac_table
  puts ""

  puts "-- dijk --"
  g.shortest_path(1, 5)
end

## test runner
if __FILE__ == $0
  test
end
