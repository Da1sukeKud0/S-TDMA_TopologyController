require "json"
require "/share/home/kudo/trema/topology/lib/dijkstra"

##
## 経路決定アルゴリズムへのトポロジ受け渡し、経路探索を行うクラス
##
class Graph
  attr_reader :map
  attr_reader :mac_table

  def initialize
    ## 経路計算アルゴリズム用に変換されたトポロジ情報
    @map = Dijkstra.new
    ## {"h1"=>mac_address,,,}
    @mac_table = Hash.new
  end

  ## main
  ## 既存の@mapに存在するノード対の経路を探索
  ##
  def getRoute(src_id, dst_id)
    ## ノード(dpid)の存在確認はアルゴリズム側で行う
    puts @map
    @map.shortest_path(src_id, dst_id)
    puts "getRoute called."
  end

  ## private
  ## Topology::@topo形式のトポロジを受け取り、経路計算アルゴリズム用に変換
  ##
  def setGraph(topo)
    puts topo
    puts "setGraph called..."

    cost = [2, 3, 4, 6, 6, 5, 2, 2, 4] ## for test

    ## Hashへのアクセサの形式が:id_a(topo直接渡し)なのか["id_a"]なのか(JSON経由)に注意
    for each in topo
      if (each[:type] == "switch2host")
        ## s2hリンクの場合
        ##@mac_table["h" + (@mac_table.size + 1).to_s] = {"id_a" => each["id_a"], "mac_address" => each["mac_address"]}
      else
        ## s2sリンクの場合
        # @map.add_edge(each[:id_a], each[:id_b], cost.shift) ## for test
        @map.add_edge(each[:id_a], each[:id_b]) ## all cost is 0
        puts "#{each[:id_a]} to #{each[:id_b]} link add...?"
      end
    end
    puts "shortest_path..."
    @map.shortest_path(1, 5)
  end

  private

  ## private
  ## jsonを展開し読み込み
  ##
  def getJSON
    # File.open("/share/home/kudo/trema/topology/test/topology.json") do |file|
    File.open("/tmp/topology.json") do |file|
      return JSON.load(file)
    end
  end
end
