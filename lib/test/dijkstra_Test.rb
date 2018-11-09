require "~/trema/topology/lib/dijkstra"
require "~/trema/topology/lib/host"

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
    File.open("/share/home/kudo/trema/topology/lib/test/resource/topology.json") do |file|
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

def test_2
  def getJSON
    File.open("/share/home/kudo/trema/topology/lib/test/resource/topology_dijkstra_test2.json") do |file|
      return JSON.load(file)
    end
  end

  topo = getJSON
  puts "-- topology --"
  puts topo
  puts ""

  puts "-- hostname => mac_address --"
  @map = Dijkstra.new
  @hst_table = Hash.new
  for each in topo
    if (each["type"] == "switch2host")
      # s2hリンクの場合
      hst_id = "h" + (@hst_table.size + 1).to_s
      @hst_table[hst_id] = each["host"]
      @map.add_edge(each["switch_a"]["dpid"], hst_id, 0) ## cost is 0
    else
      ## s2sリンクの場合
      @map.add_edge(each["switch_a"]["dpid"], each["switch_b"]["dpid"]) ## cost is 1
    end
  end
  puts @hst_table
  puts @map.graph
  puts ""

  puts "-- dijk --"
  @map.shortest_path("h1", "h5")
  puts ""

  ## 1-2間のリンクを削除
  puts "-- edge delete --"
  @map.delete_edge(1, 2)
  @map.shortest_path("h1", "h5")
end

## test runner
if __FILE__ == $0
  test_2
end
