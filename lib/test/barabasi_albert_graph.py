#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
import copy
import networkx
from networkx.generators.random_graphs import barabasi_albert_graph
from matplotlib import pyplot
import pickle


def main():
    # デフォルト引数処理
    if sys.argv and len(sys.argv) == 3:
        switchNum = int(sys.argv[1])
        complexity = int(sys.argv[2])
    else:
        switchNum = 30
        complexity = 2
    # Barabási-Albertモデルのグラフを生成
    tmp = barabasi_albert_graph(switchNum, complexity)
    # ノード番号を1からに
    edges = []
    for edge in tmp.edges():
        e = list(edge)
        e[0] += 1
        e[1] += 1
        edges.append(tuple(e))
    sorted(edges, key=lambda e: (e[0], e[1]))
    print(edges)
    # edgesから無向グラフ作成
    G = networkx.Graph()
    G.add_edges_from(edges)
    # 外部出力
    if os.path.exists('.edges'):
        os.remove('.edges')
    with open('.edges', 'w') as f:
        for l in G.edges():
            f.write(str(l) + "\n")
    networkx.draw(G, with_labels=True)
    pngpath = ".topo_ba.png"
    networkx.nx_agraph.pygraphviz_layout(G, prog='fdp')
    pyplot.tight_layout
    pyplot.savefig(pngpath)


if __name__ == '__main__':
    main()
