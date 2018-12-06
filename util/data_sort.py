#!/usr/bin/python
# -*- coding: utf-8 -*-
import json


class JsonHelper:
    def __init__(self, file_name):
        with open(file_name) as f:
            self.dics = json.load(f)
            # print(self.dics)

    # sortbyの要素毎に処理時間の平均値を算出
    def sort_by(self, sortby):
        print("")
        print("each: " + sortby)
        result = {}
        for d in self.dics:
            if (d[sortby] not in result):
                result[d[sortby]] = []
            result[d[sortby]].append(d["time"])
        self.__ave(result)

    def __ave(self, dic):
        for k, v in sorted(dic.items(), key=lambda x: x[0]):
            ave = sum(v)/len(v)
            print("key: " + str(k) + ", ave: " + str(ave))


if __name__ == '__main__':
    jh = JsonHelper("rtcm_test.json")
    jh.sort_by("turn")
    jh.sort_by("snum")
    jh.sort_by("lnum")

"""
取得したデータは配列内dict
dictのkey, valの内訳は以下
r.store("type", @type) ## トポロジタイプ
r.store("snum", @switchNum) ## スイッチ数
r.store("complexity", @complexity) ## 複雑度
r.store("rnum", num) ## RTC数
r.store("lnum", @edges.size) ## リンク数(switchNum-complexity)*complexityで算出可能
r.store("turn", n) ## RTC実行順
r.store("time", time) ## 処理時間
r.store("tf", tf) ## add_rtc?
"""
