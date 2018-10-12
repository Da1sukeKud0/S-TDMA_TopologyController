require 'json'
require 'dijkstra'

## private
## jsonを展開し読み込み
##
private def getJSON
File.open("./test/topology.json") do |file|
  return JSON.load(file)
end
end

## main
## topology内でのsrc->dstの経路探索
##
def getRoute(topo, src, dst)
  g = Graph.new
  mac_table = Hash.new
  cost = [2, 3, 4, 6, 6, 5, 2, 2, 4] ## for test
  for each in topo
    if (each["type"] == "switch2host")
      ## s2h
      mac_table["h" + (mac_table.size + 1).to_s] = {"id_a" => each["id_a"], "mac_address" => each["id_b"]}
    else
      ## s2s
      g.add_edge(each["id_a"], each["id_b"], cost.shift)
    end
  end
  g.shortest_path(src, dst)
end