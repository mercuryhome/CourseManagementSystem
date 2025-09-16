# PostgreSQL libpq 示例程序

## 文件来源

本目录下的文件来自 PostgreSQL 官方项目的示例程序：
- **来源**: [https://github.com/postgres/postgres/tree/master/src/test/examples](https://github.com/postgres/postgres/tree/master/src/test/examples)
- **用途**: 演示如何使用 libpq 库进行 PostgreSQL 数据库编程

## 包含的程序

本目录包含以下示例程序：

1. **testlibpq.c** - 基本的 libpq 连接和查询示例
2. **testlibpq2.c** - 异步通知接口测试程序
3. **testlibpq3.c** - 二进制 I/O 和参数化查询示例
4. **testlibpq4.c** - 多连接管理示例
5. **testlo.c** - 大对象 (Large Object) 操作示例
6. **testlo64.c** - 64位大对象操作示例

## 修改说明

为了实现当前目录下 `make` 成功编译，对原始的 Makefile 进行了以下修改：

### 原始问题
- 原始 Makefile 依赖 PostgreSQL 项目的构建系统
- 需要 `../../../src/Makefile.global` 文件
- 使用了项目特定的变量如 `libpq_srcdir` 和 `libpq_pgport`

### 解决方案
1. **移除项目依赖**：
   - 删除了 `include $(top_builddir)/src/Makefile.global`
   - 移除了对 PostgreSQL 项目构建系统的依赖

2. **配置 Postgres.app 路径**：
   ```makefile
   PG_INCLUDE = /Applications/Postgres.app/Contents/Versions/17/include
   PG_LIB = /Applications/Postgres.app/Contents/Versions/17/lib
   ```

3. **简化编译配置**：
   - 使用标准 gcc 编译器
   - 设置编译标志：`-Wall -g -O2 -Wno-unused-but-set-variable -Wno-unused-function`
   - 配置头文件路径：`-I$(PG_INCLUDE)`
   - 配置库文件路径：`-L$(PG_LIB) -lpq`
   - 关闭未使用变量和函数的警告

4. **添加通用构建规则**：
   ```makefile
   %: %.c
       $(CC) $(CFLAGS) $(CPPFLAGS) $< -o $@ $(LDFLAGS)
   ```

## 使用方法

### 编译所有程序
```bash
make
```

### 清理编译文件
```bash
make clean
```

### 运行示例程序
```bash
# 基本连接测试
./testlibpq

# 异步通知测试
./testlibpq2

# 二进制 I/O 测试
./testlibpq3

# 多连接测试
./testlibpq4

# 大对象测试
./testlo

# 64位大对象测试
./testlo64
```

## 系统要求

- macOS 系统
- 安装 Postgres.app (版本 17)
- gcc 编译器
- PostgreSQL 开发库 (libpq)

## 注意事项

1. 运行这些程序前，请确保 PostgreSQL 服务器正在运行
2. 某些程序需要预先创建数据库和表结构
3. 程序中的连接参数可能需要根据您的环境进行调整

## 编译结果

修改后的 Makefile 可以成功编译所有 6 个示例程序，生成可执行文件：
- testlibpq
- testlibpq2  
- testlibpq3
- testlibpq4
- testlo
- testlo64

所有程序都链接到 Postgres.app 提供的 libpq 库，可以在当前目录下独立编译和运行。
