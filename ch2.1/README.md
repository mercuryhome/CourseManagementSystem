# 学生选课管理系统数据库

## 项目简介

本项目基于王珊《数据库系统概论》第6版图2-1的学生选课数据库示例，使用PostgreSQL 17版本实现。该系统模拟了大学学生选课管理的基本功能，包含学生信息管理、课程信息管理和选课记录管理。

## 数据库结构

### 1. 学生表 (Student)
存储学生的基本信息：
- **Sno** (VARCHAR(8)): 学号，主键
- **Sname** (VARCHAR(20)): 学生姓名，非空
- **Ssex** (CHAR(1)): 性别，只能是'男'或'女'
- **Sbirthdate** (DATE): 出生日期
- **Smajor** (VARCHAR(50)): 主修专业

### 2. 课程表 (Course)
存储课程的基本信息：
- **Cno** (VARCHAR(5)): 课程号，主键
- **Cname** (VARCHAR(50)): 课程名称，非空
- **Ccredit** (INTEGER): 学分，必须大于0
- **Cpno** (VARCHAR(5)): 先修课程号，外键引用Course.Cno（自引用）

### 3. 选课表 (SC)
存储学生选课记录：
- **Sno** (VARCHAR(8)): 学号，外键引用Student.Sno
- **Cno** (VARCHAR(5)): 课程号，外键引用Course.Cno
- **Grade** (INTEGER): 成绩，0-100分
- **Semester** (VARCHAR(5)): 开课学期，格式：YYYYX（X为1或2）
- **Teachingclass** (VARCHAR(10)): 教学班编号
- **主键**: (Sno, Cno) 复合主键

## 关系约束

1. **外键约束**:
   - SC.Sno → Student.Sno
   - SC.Cno → Course.Cno
   - Course.Cpno → Course.Cno (自引用)

2. **检查约束**:
   - Student.Ssex: 只能是'男'或'女'
   - Course.Ccredit: 必须大于0
   - SC.Grade: 必须在0-100之间

## 安装和使用

### 环境要求
- PostgreSQL 17 或更高版本
- 支持UTF-8编码

### 重要说明
本SQL脚本已针对PostgreSQL 17进行了优化，主要修正包括：
- 移除了MySQL风格的 `COMMENT` 语法（PostgreSQL不支持）
- 使用PostgreSQL标准的 `COMMENT ON TABLE/COLUMN` 语法
- 提供了两种数据库创建方案以解决排序规则兼容性问题

### 安装步骤

1. **安装PostgreSQL 17**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install postgresql-17
   
   # macOS (使用Homebrew)
   brew install postgresql@17
   
   # Windows
   # 从官网下载安装包：https://www.postgresql.org/download/windows/
   ```

2. **创建数据库**
   
   **方案1：使用默认排序规则（推荐）**
   ```sql
   CREATE DATABASE db_cms
       WITH 
       OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;
   ```
   
   **方案2：如果需要中文排序规则，使用template0模板**
   ```sql
   CREATE DATABASE db_cms
       WITH 
       OWNER = postgres
       ENCODING = 'UTF8'
       LC_COLLATE = 'zh_CN.UTF-8'
       LC_CTYPE = 'zh_CN.UTF-8'
       TEMPLATE = template0
       TABLESPACE = pg_default
       CONNECTION LIMIT = -1;
   ```

3. **执行SQL脚本**
   ```bash
   psql -U postgres -d db_cms -f p2.1.sql
   ```

### 验证安装

执行以下查询验证数据库是否正确创建：

```sql
-- 查看表结构
\d Student
\d Course
\d SC

-- 查看数据统计
SELECT 'Student表数据' as table_name, COUNT(*) as record_count FROM Student
UNION ALL
SELECT 'Course表数据' as table_name, COUNT(*) as record_count FROM Course
UNION ALL
SELECT 'SC表数据' as table_name, COUNT(*) as record_count FROM SC;

-- 查看表注释
SELECT 
    schemaname,
    tablename,
    tablecomment
FROM pg_tables t
LEFT JOIN pg_description d ON d.objoid = t.tableid
WHERE schemaname = 'public';

-- 查看字段注释
SELECT 
    c.table_name,
    c.column_name,
    pgd.description as column_comment
FROM pg_catalog.pg_statio_all_tables as st
INNER JOIN pg_catalog.pg_description pgd on (pgd.objoid=st.relid)
INNER JOIN information_schema.columns c on (
    pgd.objsubid=c.ordinal_position AND
    c.table_schema=st.schemaname AND
    c.table_name=st.relname
)
WHERE c.table_schema = 'public'
ORDER BY c.table_name, c.ordinal_position;
```

## 示例查询

### 1. 查询所有学生信息
```sql
SELECT * FROM Student;
```

### 2. 查询所有课程信息
```sql
SELECT * FROM Course;
```

### 3. 查询学生选课成绩
```sql
SELECT 
    s.Sname as 学生姓名,
    c.Cname as 课程名称,
    sc.Grade as 成绩,
    sc.Semester as 学期
FROM SC sc
JOIN Student s ON sc.Sno = s.Sno
JOIN Course c ON sc.Cno = c.Cno
ORDER BY s.Sname, c.Cname;
```

### 4. 查询课程先修关系
```sql
SELECT 
    c1.Cname as 课程名称,
    c2.Cname as 先修课程
FROM Course c1
LEFT JOIN Course c2 ON c1.Cpno = c2.Cno
ORDER BY c1.Cno;
```

### 5. 统计各专业学生人数
```sql
SELECT 
    Smajor as 专业,
    COUNT(*) as 学生人数
FROM Student
GROUP BY Smajor
ORDER BY 学生人数 DESC;
```

## 索引优化

为了提高查询性能，已创建以下索引：
- `idx_student_major`: 学生专业索引
- `idx_course_credit`: 课程学分索引
- `idx_sc_grade`: 选课成绩索引
- `idx_sc_semester`: 选课学期索引

## 数据完整性

系统通过以下机制保证数据完整性：
1. **主键约束**: 确保唯一性
2. **外键约束**: 确保引用完整性
3. **检查约束**: 确保数据有效性
4. **非空约束**: 确保必要字段不为空

## 扩展功能建议

1. **用户管理**: 添加用户表和权限管理
2. **教师管理**: 添加教师表和授课关系
3. **成绩统计**: 添加成绩统计和排名功能
4. **选课限制**: 添加选课时间和人数限制
5. **日志记录**: 添加操作日志记录功能

## 常见问题解决

### 1. 排序规则错误
如果遇到 `new collation (zh_CN.UTF-8) is incompatible` 错误：
- 使用方案1（默认排序规则）创建数据库
- 或使用方案2（template0模板）创建数据库

### 2. COMMENT语法错误
如果遇到 `syntax error at or near "COMMENT"` 错误：
- PostgreSQL不支持MySQL风格的COMMENT语法
- 本脚本已修正为使用PostgreSQL标准的COMMENT语法

### 3. 字符编码问题
确保数据库使用UTF-8编码以正确支持中文字符

## 技术支持

如有问题，请检查：
1. PostgreSQL版本是否支持（推荐17+）
2. 字符编码是否正确设置（UTF-8）
3. 数据库连接权限是否配置正确
4. 是否使用了正确的SQL脚本版本

## 许可证

本项目仅用于学习和研究目的。
