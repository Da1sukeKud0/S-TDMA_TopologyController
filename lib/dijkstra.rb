require "json"

class Dijkstra
  attr_reader :graph, :nodes, :previous, :distance # getter
  INFINITY = 1 << 64

  def initialize
    @graph = {} ## {node=>{dst=>cost}}
    @nodes = []
  end

  ## sub
  ## ノードの存在確認(簡易。同名のIDが存在するかどうか)
  ##
  # def include?(node)
  #   return @nodes.include?(node)
  # end

  ## main
  ## 無向グラフを作成
  ##
  def add_edge(src, dst, weight)
    src = src.to_s
    dst = dst.to_s
    connect_graph(src, dst, weight) ## src -> dst
    connect_graph(dst, src, weight) ## dst -> src
  end

  ## main
  ## ダイクストラ法
  ##
  def dijkstra(src)
    @distance = {}
    @previous = {}
    nodes.each do |node|
      @distance[node] = INFINITY ## ノードまでのコストを無限大に設定
      @previous[node] = -1 ##
    end
    @distance[src] = 0 ## src2srcのコスト
    unvisited_node = nodes.compact ## nilのノードを除く
    while unvisited_node.size > 0
      u = nil
      unvisited_node.each do |min|
        u = min if (!u) || (@distance[min] && @distance[min] < @distance[u])
      end
      break if @distance[u] == INFINITY
      unvisited_node -= [u]
      graph[u].keys.each do |vertex|
        alt = @distance[u] + graph[u][vertex]
        if alt < @distance[vertex]
          @distance[vertex] = alt
          @previous[vertex] = u # ノードvへの最短パス
        end
      end
    end
  end

  ## main
  ## 最短パスを探索
  ##
  def shortest_path(src, dst)
    src = src.to_s
    dst = dst.to_s
    ## 経路の解を格納
    @solved_paths = []
    @src = src
    dijkstra src
    # nodes.each do |dst|
    @path = []
    find_path dst
    if (@distance[dst] != INFINITY)
      actual_distance = @distance[dst]
    else
      actual_distance = "no path"
    end
    @solved_paths.push("src" => src, "dst" => dst, "path" => @path, "cost" => actual_distance)
    # end
    output_cli
    @solved_paths
  end

  private

  def connect_graph(src, dst, weight)
    if !graph.key?(src)
      graph[src] = {dst => weight}
    else
      graph[src][dst] = weight
    end
    nodes.push(src) unless nodes.include?(src)
  end

  def find_path(dst)
    if (@previous[dst] != -1)
      find_path @previous[dst]
    end
    @path << dst
  end

  def output_cli
    @solved_paths.each do |each|
      puts each
    end
  end

  def output_path
    return @path
  end
end

## test
## native source code test
##
def test
  g = Graph.new
  g.add_edge("a", "c", 7)
  g.add_edge("a", "e", 14)
  g.add_edge("a", "f", 9)
  g.add_edge("c", "d", 15)
  g.add_edge("c", "f", 10)
  g.add_edge("d", "f", 11)
  g.add_edge("d", "b", 6)
  g.add_edge("f", "e", 2)
  g.add_edge("e", "b", 9)
  g.shortest_paths("a", "b")
end

## test
## JSON test
##
def testJSON
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
