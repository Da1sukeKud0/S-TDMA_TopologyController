require "json"

class Dijkstra
  attr_reader :graph, :nodes, :previous, :distance # getter
  INFINITY = 1 << 64

  def initialize
    @graph = {} ## {node=>{dst=>cost}}
    @nodes = []
  end

  ## main
  ## 無向グラフを作成
  ##
  def add_edge(src, dst, weight = 1)
    src = src.to_s
    if (dst.class != String)
      dst = dst.to_s
    end
    connect_graph(src, dst, weight) ## src -> dst
    connect_graph(dst, src, weight) ## dst -> src
  end

  def delete_edge(src, dst)
    src = src.to_s
    if (dst.class != String)
      dst = dst.to_s
    end
    unconnect_graph(src, dst)
    unconnect_graph(dst, src)
    # puts "delete#{src}to#{dst}"
  end

  def unconnect_graph(src, dst)
    ## graphから削除
    ## graph[src]が空ならnode削除
    if graph.key?(src)
      graph[src].delete(dst)
      graph.delete(src) if (graph[src].size == 0)
    end
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
      return false if (!graph[u]) ## test
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
    ## src,dst各ノードの存在確認
    if (!@nodes.include?(src) || !@nodes.include?(dst))
      # puts "such node is not exist."
      return false
    end
    ## 経路の解を格納
    # @solved_paths = []
    @src = src
    dijkstra src
    # nodes.each do |dst|
    @path = []
    find_path dst
    if (@distance[dst] != INFINITY) ##ルーティング可能
      actual_distance = @distance[dst]
      #pathの変換
      @solved_path = []
      for i in Range.new(1, (@path.size - 1))
        @solved_path.push({src: @path[i - 1], dst: @path[i]})
      end
    else ##ルーティング不可
      return false
    end
    # end
    # puts "solved path is #{@solved_path}"
    return @solved_path
  end

  private

  def connect_graph(src, dst, weight)
    if !graph.key?(src)
      graph[src] = {dst => weight}
    else
      graph[src][dst] = weight
    end
    # nodes.push(src) unless nodes.include?(src)
    # puts "node #{src} is added" unless nodes.include?(src)
    if !nodes.include?(src)
      nodes.push(src)
    end
  end

  def find_path(dst)
    if (@previous[dst] != -1)
      find_path @previous[dst]
    end
    @path << dst
  end

  # def output_cli
  #   @solved_paths.each do |each|
  #     puts each
  #   end
  # end

end
