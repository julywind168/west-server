# west-server
A skynet distributed server template

## Features
1. 一套代码, 相同的启动脚本, 相同的代码, 可以做到随时在单机和集群模式之间的切换。
    * 单机模式: 用于开发时使用。
    * 集群模式: 用于生产时使用。(在开发时, 如有需要, 可以将项目复制多份来模拟集群模式)

2. 使用 rust 来编写 native lua libs
    * 统一的编译的方式, 告别 各种 c/cpp 乱七八糟的 Makefile
    * rust 更安全, 生态强大
    * 逐步添加各种实用的 libs, 比如 json, uuid, ring ...

3. 通用的 skynet lua libs 
    * log: 日志库
    * mongo: 支持连接池, 支持 mongo empty array
    * echo: golang echo 风格的 web 框架
    * list: 函数式风格 table 扩展
    * ...

4. simple service sandbox, 参考 service/simple/ping.lua 即可便捷的更新服务的状态或接口

## Build
Please install rust first.
```bash
./install.sh skynet
./install.sh libs
```

## Test
```bash
./start.sh
```