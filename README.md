topologyManager
========
[![Build Status](http://img.shields.io/travis/Da1sukeKud0/topology/develop.svg?style=flat)][travis]
[![Code Climate](http://img.shields.io/codeclimate/github/Da1sukeKud0/topology.svg?style=flat)][codeclimate]
[![Coverage Status](http://img.shields.io/codeclimate/coverage/github/Da1sukeKud0/topology.svg?style=flat)][codeclimate]
[![Dependency Status](http://img.shields.io/gemnasium/Da1sukeKud0/topology.svg?style=flat)][gemnasium]

[travis]: https://travis-ci.org/Da1sukeKud0/topology
[codeclimate]: https://codeclimate.com/github/Da1sukeKud0/topology
[gemnasium]: https://gemnasium.com/trema/topology


実行環境
-------------
* Ruby 2.3.7
* [Open vSwitch][openvswitch] (`apt-get install openvswitch-switch`).

[rvm]: https://rvm.io/
[openvswitch]: https://openvswitch.org/


インストール
-------
```
$ git clone https://github.com/Da1sukeKud0/topology.git
$ cd topology
$ bundle install --binstubs
```


使用方法
----

コントローラの起動（`-c`オプションにより任意の初期トポロジを設定）
```
$ ./bin/trema run ./lib/topology_controller.rb -c test/linear.conf
```

スイッチの起動/停止
```
$ ./bin/trema stop 0x1
$ ./bin/trema start 0x1
```

スイッチポートの起動/停止
```
$ ./bin/trema port_down --switch 0x1 --port 1
$ ./bin/trema port_up --switch 0x1 --port 1
```

ホストをスイッチに追加（実際にはスイッチもポートも存在するが以下によるPacket_Inでリンクが検出される）
```
$ ./bin/trema send_packets -n 1 -s h1 -d h2
```

宛先MACアドレスの変更
```
$ ./bin/trema run ./lib/topology_controller.rb -c fullmesh.conf -- --destination_mac 11:22:33:44:55:66
```
