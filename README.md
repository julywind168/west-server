# west-server
A skynet distributed server template

## Features
1. 一流的 hotfix, 参考 service/simple/ping.lua 即可便捷的更新服务的状态或接口。

2. 相同的启动脚本, 相同的代码, 配合 west api 可以做到随时在单机和集群模式之间的切换。
    * 单机模式: 用于开发或生产环境。
    * 集群模式: 用于生产环境。

3. 使用 rust 来编写 native lua libs
    * 统一的编译的方式, 告别 各种 c/cpp 乱七八糟的 Makefile
    * rust 更安全, 生态强大
    * 逐步添加各种实用的 libs, 比如 json, uuid, ...

4. 通用的 skynet lua libs 
    * west.log: 日志库 (按每日分割)
    * west.timer: 定时器
    * west.mq: 跨节点的 消息队列 (pub/sub)
    * west.mongo: 支持连接池, 支持 mongo empty array
    * west.redis: redis lib
    * west.sqlx: mysql lib
    * west.echo: golang echo 风格的 web 框架
    * west.pool: service pool (simple service 在 vm 实例化时不会加载对应的业务代码, 所以在 clearcache 时, 无需清空 pool)
    * west.list/dict: 函数式编程风格 table 扩展
    * ...

## 最佳实践 & West API
1. 业务 service, 请在 simple service 规范下开发
2. west.spawn(name, sname, ...) 启动一个 sname (service/simple/?.lua) 的 simple 服务 并命名为 name
    * name: string, 需要在本地节点内唯一, 比如 "room_mgr", "room.100001", "room.100002", ...
3. west.call(name, ...) 底层调用 skynet.call | cluster.call
4. west.send(name, ...) 底层调用 skynet.send | cluster.send
5. west.self() 获取当前 simple 服务的名字, 根据是否启动了集群 返回类似 "node1@room_mgr" | "room_mgr"
6. 通过 simple service 和 west api, 抹平了 集群和单机模式的差异
7. simple service 支持一流的 hotfix, 只需要将状态都挂接在 service self 中即可 (见 service/simple/ping.lua 和下面的 Test Hotfix 章节)

## Install
1. rust
2. rlwrap
3. nc

## Build
```bash
./install.sh skynet
./install.sh libs
```

## Test
```bash
./start.sh
```

## Test Hotfix
```bash
rlwrap nc 127.0.0.1 {DEBUG_PORT}
list
inject [ping_addr] hotfix/fix_ping.lua
```

## Test Distributed
开发时, 如果需要在 daemon 模式下模拟 集群模式, 需要复制项目 (原因: skynet.pid log ... 会冲突)
```bash
./start.sh -n ping
./start.sh -n main (another terminal)
```