#!/usr/bin/python
# -*- coding: utf-8 -*-
import json


class JsonHelper:
    def __init__(self, file_name):
        with open(file_name) as f:
            self.dics = json.load(f)
            print(self.dics)

    def sort_by_turn(self):
        turn = {}
        for d in self.dics:
            if (d["turn"] not in turn):
                turn[d["turn"]] = []
            turn[d["turn"]].append(d["time"])
        self.__ave(turn)

    def __ave(self, dic):
        for k, v in dic.items():
            ave = sum(v)/len(v)
            print("key: " + str(k) + ", ave: " + str(ave))


if __name__ == '__main__':
    sorter = JsonHelper("BA_s30_cplx2_rtc3.json")
    sorter.sort_by_turn()
