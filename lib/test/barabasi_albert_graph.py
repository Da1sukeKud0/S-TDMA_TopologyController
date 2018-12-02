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
    # Barabási-Albertモデルのグラフを生成
    args = sys.argv
    G = barabasi_albert_graph(int(args[1]), int(args[2]))
    print(G.edges())
    # 外部出力
    if os.path.exists('.edges'):
        os.remove('.edges')
    with open('.edges', 'w') as f:
        for l in G.edges():
            f.write(str(l) + "\n")
    return G.edges()


if __name__ == '__main__':
    main()
