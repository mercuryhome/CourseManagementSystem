# PostgreSQL C 客户端程序

这个目录包含用于连接和操作PostgreSQL数据库的C语言程序。

## 文件说明

- `test_select_student.c` - 演示程序，连接PostgreSQL数据库并查询学生表的前5条记录
- `Makefile` - 编译配置文件
- `README.md` - 本说明文件

## 环境要求

### 1. PostgreSQL 数据库
确保PostgreSQL服务正在运行：
```bash
# macOS 使用 Homebrew
brew services start postgresql@17

# 检查服务状态
lsof -i:5432
```

### 2. 数据库设置
确保已创建数据库和表：
```sql
-- 连接数据库
psql -U postgres -h localhost -p 5432 -d postgres

-- 创建数据库
CREATE DATABASE db_cms_dev;

-- 连接新数据库
\c db_cms_dev

-- 创建模式
CREATE SCHEMA en;

-- 创建学生表
CREATE TABLE en.Student (
    Sno CHAR(8) PRIMARY KEY,
    Sname VARCHAR(20) UNIQUE, 
    Ssex CHAR(6),
    Sbirthdate DATE,
    Smajor VARCHAR(40)
);

-- 插入测试数据
INSERT INTO en.Student (Sno, Sname, Ssex, Sbirthdate, Smajor) VALUES
('20180001', '李勇', '男', '2000-03-08', '信息安全'),
('20180002', '刘晨', '女', '1999-09-01', '计算机科学与技术'),
('20180003', '王敏', '女', '2001-08-01', '信息管理与信息系统'),
('20180004', '张立', '男', '2000-01-08', '数据科学与大数据技术'),
('20180005', '陈新奇', '男', '2001-11-01', '信息安全');
```

### 3. 开发环境
- GCC 编译器
- PostgreSQL 开发库 (libpq)

#### macOS 安装开发库：
```bash
# 使用 Homebrew
brew install postgresql

# 验证安装
pg_config --version
```

#### Ubuntu/Debian 安装开发库：
```bash
sudo apt-get install postgresql-server-dev-all
```

## 编译和运行

### 1. 检查PostgreSQL配置
```bash
make check-pg
```

### 2. 编译程序
```bash
make
```

### 3. 运行程序
```bash
make run
```

或者直接运行：
```bash
./test_select_student
```

### 4. 清理编译文件
```bash
make clean
```

## 配置说明

### 数据库连接参数
在 `test_select_student.c` 中修改连接字符串：
```c
const char *conninfo = "host=localhost port=5432 dbname=db_cms_dev user=postgres password=your_password";
```

请将 `your_password` 替换为实际的PostgreSQL用户密码。

### 常见问题

1. **连接失败**
   - 检查PostgreSQL服务是否运行
   - 验证用户名和密码
   - 确认数据库名称正确

2. **编译错误**
   - 确保已安装PostgreSQL开发库
   - 检查pg_config是否在PATH中

3. **权限问题**
   - 确保用户有访问数据库的权限
   - 检查模式权限设置

## 程序功能

`test_select_student.c` 程序执行以下操作：

1. 连接到PostgreSQL数据库 (localhost:5432, db_cms_dev)
2. 查询en模式下的Student表前5条记录
3. 格式化输出查询结果
4. 清理数据库连接资源

输出示例：
```
正在连接PostgreSQL数据库...
连接信息: host=localhost port=5432 dbname=db_cms_dev user=postgres password=***
数据库连接成功！

执行查询: SELECT Sno, Sname, Ssex, Sbirthdate, Smajor FROM en.Student LIMIT 5

查询结果 (共 5 条记录):
=============================================================
Sno         Sname             Ssex    Sbirthdate    Smajor                      
------------ ------------------ -------- -------------- ----------------------------
20180001     李勇               男       2000-03-08     信息安全                    
20180002     刘晨               女       1999-09-01     计算机科学与技术            
20180003     王敏               女       2001-08-01     信息管理与信息系统          
20180004     张立               男       2000-01-08     数据科学与大数据技术        
20180005     陈新奇             男       2001-11-01     信息安全                    
=============================================================
查询完成！
```

## 程序特性

### 智能中文字符对齐
程序实现了智能的中文字符对齐系统：
- **字符宽度计算**：正确识别中文字符的显示宽度（2个字符宽度）
- **精确填充**：根据实际显示宽度智能填充空格
- **完美对齐**：确保所有列都完美对齐，无论中文字符如何显示
