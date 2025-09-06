# 第3章 SQL实验指导

## 实验一：SQL环境配置与数据定义

### 1.1 实验目的
1. 掌握PostgreSQL数据库环境的配置方法
2. 理解数据库、模式、表的概念及其关系
3. 掌握使用DDL语句创建、修改、删除数据库对象
4. 理解完整性约束的作用和定义方法

### 1.2 实验环境
- **操作系统**: MacOSX
- **数据库管理系统**: PostgreSQL 17
- **数据库名称**: db_cms_dev
- **实验模式**: en

### 1.3 实验内容

#### 步骤1：环境准备
```bash
# 安装PostgreSQL
brew install postgresql@17

# 查看 PostgreSQL 的安装目录
brew --prefix postgresql@17

# 添加 PostgreSQL路径至PATH（适用于现代Mac系统）
# 方法1：添加到 .zshrc（推荐，适用于macOS Catalina及以后版本）
echo 'export PATH="$(brew --prefix postgresql@17)/bin:$PATH"' >> ~/.zshrc

# 方法2：添加到 .bash_profile（适用于使用Bash的用户）
echo 'export PATH="$(brew --prefix postgresql@17)/bin:$PATH"' >> ~/.bash_profile

# 方法3：添加到 .profile（通用方法）
echo 'export PATH="$(brew --prefix postgresql@17)/bin:$PATH"' >> ~/.profile

echo "PostgreSQL PATH: $(which psql)"

# 启动PostgreSQL服务
brew services start postgresql@17

# 停止PostgreSQL服务
brew services stop postgresql@17

# 重启PostgreSQL服务
brew services restart postgresql@17

# 查看PostgreSQL进程状态
lsof -i:5432
ps -ef | grep postgres

# 查看PostgreSQL进程树（可选）
brew install pstree
lsof -i:5432 | grep LISTEN | awk '{print $2}' | xargs pstree -p

# 连接到数据库（PostgreSQL 17安装后可能没有postgres用户）
# 方法1：直接连接（如果系统自动创建了用户）
psql -U postgres -h localhost -p 5432 -d postgres

# 方法2：无用户连接（推荐，适用于新安装的PostgreSQL 17）
psql -h localhost -d postgres

# 如果连接失败，可能需要初始化数据库
# 首先检查Mac架构
uname -m

# 根据架构选择正确的路径：
# Intel Mac (x86_64) - 使用 /usr/local/var/
initdb /usr/local/var/postgresql@17

# Apple Silicon Mac (ARM64) - 使用 /opt/homebrew/var/
initdb /opt/homebrew/var/postgresql@17

# 或者使用Homebrew的默认路径（推荐）
brew services list | grep postgresql
```

**注意事项**：
- **重要**：PostgreSQL 17安装后可能没有默认的`postgres`用户，需要手动创建
- 如果连接时提示需要密码，可以设置环境变量：`export PGPASSWORD=your_password`
- 或者修改`pg_hba.conf`文件允许本地无密码连接
- **Mac架构差异**：
  - Intel Mac (x86_64)：Homebrew安装在`/usr/local/`
  - Apple Silicon Mac (ARM64)：Homebrew安装在`/opt/homebrew/`
  - 使用`uname -m`命令可以查看当前Mac的架构类型

#### 创建postgres用户（如果不存在）
```sql
-- 1. 使用无用户方式连接数据库
psql -h localhost -d postgres

-- 2. 在psql环境中创建postgres角色
CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'your_password';

-- 3. 验证用户创建成功
\du

-- 4. 退出psql
\q

-- 5. 使用新创建的postgres用户连接
psql -U postgres -h localhost -p 5432 -d postgres
```

#### 步骤2：创建数据库和模式
```sql
-- 创建数据库（如果尚未创建）
CREATE DATABASE db_cms_dev;

-- 创建模式：英语系， 中文系
CREATE SCHEMA en;
CREATE SCHEMA cn;

-- 设置模式搜索路径
SET search_path TO en, cn, public;

-- 授权当前用户在模式上创建对象的权限
GRANT CREATE ON SCHEMA en, cn TO current_user;

-- 验证模式创建成功
SELECT schema_name FROM information_schema.schemata 
WHERE schema_name IN ('en', 'cn');
```

#### 步骤3：创建基本表
```sql
-- 创建学生表
CREATE TABLE en.Student (
    Sno CHAR(8) PRIMARY KEY,                -- 学号，主键
    Sname VARCHAR(20) UNIQUE,               -- 姓名，唯一约束
    Ssex CHAR(6),                           -- 性别
    Sbirthdate DATE,                        -- 出生日期
    Smajor VARCHAR(40)                      -- 专业
);

-- 创建课程表（注意自参照外键）
CREATE TABLE en.Course (
    Cno VARCHAR(5) PRIMARY KEY,             -- 课程号，主键
    Cname VARCHAR(40) NOT NULL,             -- 课程名，非空约束
    Ccredit SMALLINT NOT NULL CHECK (Ccredit > 0), -- 学分，检查约束
    Cpno VARCHAR(5),                        -- 先修课程号
    FOREIGN KEY (Cpno) REFERENCES en.Course(Cno) -- 自参照外键
);

-- 创建选课表
CREATE TABLE en.SC (
    Sno CHAR(8) NOT NULL,                   -- 学号，与Student表保持一致
    Cno VARCHAR(5) NOT NULL,                -- 课程号
    Grade SMALLINT CHECK (Grade >= 0 AND Grade <= 100), -- 成绩，检查约束
    Semester VARCHAR(5) NOT NULL CHECK (Semester ~ '^[0-9]{4}[12]$'), -- 学期，正则检查
    Teachingclass VARCHAR(8),               -- 教学班
    PRIMARY KEY (Sno, Cno, Semester),       -- 复合主键
    FOREIGN KEY (Sno) REFERENCES en.Student(Sno) ON DELETE CASCADE,
    FOREIGN KEY (Cno) REFERENCES en.Course(Cno),
    CONSTRAINT uk_sc_student_teachingclass UNIQUE (Sno, Teachingclass, Semester) -- 唯一约束
);
```

#### 步骤4：验证表结构
```sql
-- 查看表结构
\d en.Student
\d en.Course
\d en.SC

-- 查看约束信息
SELECT conname, contype, conkey 
FROM pg_constraint 
WHERE conrelid = 'en.sc'::regclass;
```

#### 步骤5：表结构修改（ALTER TABLE）
```sql
-- 1. 添加新列
ALTER TABLE en.Student ADD COLUMN Sphone VARCHAR(15);
ALTER TABLE en.Student ADD COLUMN Semail VARCHAR(50);

-- 2. 修改列属性
ALTER TABLE en.Student ALTER COLUMN Sname TYPE VARCHAR(30);
ALTER TABLE en.Student ALTER COLUMN Sphone SET DEFAULT '未填写';

-- 3. 添加约束
ALTER TABLE en.Student ADD CONSTRAINT chk_phone 
    CHECK (Sphone ~ '^[0-9]{11}$' OR Sphone IS NULL);

-- 4. 删除列
ALTER TABLE en.Student DROP COLUMN Semail;

-- 5. 重命名列
ALTER TABLE en.Student RENAME COLUMN Sphone TO Phone;

-- 6. 重命名表
ALTER TABLE en.Student RENAME TO Students;

-- 恢复原名
ALTER TABLE en.Students RENAME TO Student;
```

#### 步骤6：删除数据库对象
```sql
-- 1. 创建临时表用于演示
CREATE TABLE en.temp_table (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20)
);

-- 2. 删除表
DROP TABLE IF EXISTS en.temp_table;

-- 3. 创建临时视图
CREATE VIEW en.temp_view AS SELECT Sno, Sname FROM en.Student;

-- 4. 删除视图
DROP VIEW IF EXISTS en.temp_view;
```

### 1.4 常见问题与解决方案

#### 问题1：连接数据库失败
```bash
# 错误信息：psql: error: connection to server on socket "/tmp/.s.PGSQL.5432" failed
# 解决方案：
brew services restart postgresql@17
# 或者检查服务状态
brew services list | grep postgresql
```

#### 问题2：权限不足错误
```sql
-- 错误信息：ERROR: permission denied for schema en
-- 解决方案：
GRANT USAGE ON SCHEMA en TO current_user;
GRANT CREATE ON SCHEMA en TO current_user;
```

#### 问题3：外键约束违反
```sql
-- 错误信息：ERROR: insert or update on table "sc" violates foreign key constraint
-- 解决方案：确保引用的学生和课程记录存在
SELECT * FROM en.Student WHERE Sno = '20180001';
SELECT * FROM en.Course WHERE Cno = '81001';
```

### 1.5 实验思考题
1. 为什么Course表的Cpno字段要定义为外键？这种设计有什么好处？
2. SC表为什么使用(Sno, Cno, Semester)作为复合主键？这与传统的(Sno, Cno)主键有什么区别？
3. 检查约束`Semester ~ '^[0-9]{4}[12]$'`的含义是什么？
4. 如果删除一个被其他表引用的学生记录，会发生什么？如何避免数据不一致？

---

## 实验二：数据操作与查询

### 2.1 实验目的
1. 掌握使用DML语句插入、更新、删除数据
2. 掌握基本的单表查询语句
3. 理解空值的概念和处理方法
4. 掌握数据完整性约束的验证

### 2.2 实验内容

#### 步骤1：插入示例数据
```sql
-- 插入学生数据
INSERT INTO en.Student (Sno, Sname, Ssex, Sbirthdate, Smajor) VALUES
('20180001', '李勇', '男', '2000-03-08', '信息安全'),
('20180002', '刘晨', '女', '1999-09-01', '计算机科学与技术'),
('20180003', '王敏', '女', '2001-08-01', '信息管理与信息系统'),
('20180004', '张立', '男', '2000-01-08', '数据科学与大数据技术'),
('20180005', '陈新奇', '男', '2001-11-01', '信息安全'),
('20180006', '赵明', '男', '2000-06-12', '计算机科学与技术'),
('20180007', '王佳佳', '女', '2001-12-07', '信息管理与信息系统');

-- 插入课程数据（注意插入顺序）
INSERT INTO en.Course (Cno, Cname, Ccredit, Cpno) VALUES
('81001', '程序设计基础与C语言', 4, NULL),
('81007', '离散数学', 3, NULL),
('81002', '数据结构', 4, '81001'),
('81005', '操作系统', 4, '81001'),
('81003', '数据库系统概论', 3, '81002'),
('81006', 'Python语言', 3, '81002'),
('81004', '信息系统概论', 3, '81003'),
('81008', '大数据技术概论', 3, '81003');

-- 插入选课数据
INSERT INTO en.SC (Sno, Cno, Grade, Semester, Teachingclass) VALUES
('20180001', '81001', 85, '20192', '81001-01'),
('20180001', '81002', 96, '20201', '81002-01'),
('20180001', '81003', 87, '20202', '81003-01'),
('20180002', '81001', 80, '20192', '81001-02'),
('20180002', '81002', 98, '20201', '81002-02'),
('20180002', '81003', 71, '20202', '81003-02'),
('20180003', '81001', 81, '20192', '81001-01'),
('20180003', '81002', 76, '20201', '81002-01'),
('20180003', '81003', 56, '20202', '81003-01'),
('20180004', '81001', 97, '20192', '81001-02'),
('20180004', '81002', 68, '20201', '81002-02');
```

#### 步骤2：基础查询练习
```sql
-- 1. 查询所有学生信息
SELECT * FROM en.Student;

-- 2. 查询计算机科学与技术专业的学生姓名和学号
SELECT Sname, Sno FROM en.Student WHERE Smajor = '计算机科学与技术';

-- 3. 查询2000年以后出生的学生
SELECT Sname, Sbirthdate FROM en.Student WHERE Sbirthdate > '2000-01-01';

-- 4. 查询成绩在90分以上的选课记录
SELECT * FROM en.SC WHERE Grade > 90;

-- 5. 查询每个学生的年龄（计算字段）
SELECT Sname, EXTRACT(YEAR FROM age(current_date, Sbirthdate)) AS Age 
FROM en.Student;

-- 6. 模糊查询：查询姓李的学生
SELECT * FROM en.Student WHERE Sname LIKE '李%';

-- 7. 范围查询：查询成绩在80-90分之间的记录
SELECT * FROM en.SC WHERE Grade BETWEEN 80 AND 90;

-- 8. 排序查询：按出生日期降序排列学生
SELECT Sname, Sbirthdate FROM en.Student ORDER BY Sbirthdate DESC;

-- 9. 分组查询：统计每个专业的学生人数
SELECT Smajor, COUNT(*) AS Student_Count FROM en.Student GROUP BY Smajor;

-- 10. 去重查询：查询所有不同的专业
SELECT DISTINCT Smajor FROM en.Student;

-- 11. 条件组合查询：查询计算机专业且2000年后出生的学生
SELECT Sname, Sbirthdate FROM en.Student 
WHERE Smajor = '计算机科学与技术' AND Sbirthdate > '2000-01-01';

-- 12. 空值查询：查询没有成绩的选课记录
SELECT * FROM en.SC WHERE Grade IS NULL;
```

#### 步骤3：数据更新操作
```sql
-- 1. 插入新学生
INSERT INTO en.Student (Sno, Sname, Ssex, Sbirthdate, Smajor)
VALUES ('20180008', '测试学生', '男', '2002-05-15', '网络安全');

-- 2. 修改学生专业
UPDATE en.Student SET Smajor = '数据科学与大数据技术' 
WHERE Sno = '20180003';

-- 3. 成绩调整（按比例提高，不超过100分）
UPDATE en.SC 
SET Grade = LEAST(Grade * 1.05, 100)
WHERE Cno = '81003' AND Semester = '20202';

-- 4. 删除学生记录（观察外键约束的级联删除）
DELETE FROM en.Student WHERE Sno = '20180007';
```

#### 步骤4：空值处理
```sql
-- 1. 插入缺考记录
INSERT INTO en.SC (Sno, Cno, Grade, Semester, Teachingclass)
VALUES ('20180005', '81001', NULL, '20192', '81001-03');

-- 2. 查询缺考学生
SELECT * FROM en.SC WHERE Grade IS NULL;

-- 3. 查询不及格或缺考的学生
SELECT Sno, Cno, Grade 
FROM en.SC 
WHERE Grade < 60 OR Grade IS NULL;

-- 4. 验证数据完整性
-- 检查外键约束
SELECT COUNT(*) FROM en.SC sc 
WHERE NOT EXISTS (SELECT 1 FROM en.Student s WHERE s.Sno = sc.Sno);

-- 检查学期格式
SELECT * FROM en.SC WHERE Semester !~ '^[0-9]{4}[12]$';

-- 检查成绩范围
SELECT * FROM en.SC WHERE Grade < 0 OR Grade > 100;
```

### 2.3 实验思考题
1. 在插入课程数据时，为什么要先插入Cpno为NULL的记录？
2. 如果尝试删除一个已经被SC表引用的学生记录，会发生什么？为什么？
3. 空值（NULL）与0有什么区别？在查询中应该如何处理空值？

---

## 实验三：高级查询与数据操作

### 3.1 实验目的
1. 掌握多表连接查询
2. 理解和使用嵌套查询（子查询）
3. 掌握集合查询操作
4. 学习复杂的数据更新操作

### 3.2 实验内容

#### 步骤1：连接查询
```sql
-- 1. 等值连接：查询学生选课详细信息
SELECT s.Sno, s.Sname, c.Cno, c.Cname, sc.Grade, sc.Semester
FROM en.Student s, en.SC sc, en.Course c
WHERE s.Sno = sc.Sno AND sc.Cno = c.Cno;

-- 2. 使用JOIN的现代写法
SELECT s.Sno, s.Sname, c.Cno, c.Cname, sc.Grade, sc.Semester
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
JOIN en.Course c ON sc.Cno = c.Cno;

-- 3. 左外连接：查询所有学生的选课情况（包括没选课的学生）
SELECT s.Sno, s.Sname, sc.Cno, sc.Grade
FROM en.Student s
LEFT JOIN en.SC sc ON s.Sno = sc.Sno;

-- 4. 自连接：查询每门课程的先修课程信息
SELECT c1.Cno, c1.Cname, c2.Cname AS Prerequisite_Course
FROM en.Course c1
LEFT JOIN en.Course c2 ON c1.Cpno = c2.Cno;
```

#### 步骤2：嵌套查询
```sql
-- 1. 带有IN的子查询：查询选修了"数据库系统概论"的学生
SELECT Sno, Sname 
FROM en.Student 
WHERE Sno IN (
    SELECT Sno FROM en.SC WHERE Cno = (
        SELECT Cno FROM en.Course WHERE Cname = '数据库系统概论'
    )
);

-- 2. 带有比较运算符的子查询：查询高于平均成绩的选课记录
SELECT Sno, Cno, Grade
FROM en.SC
WHERE Grade > (SELECT AVG(Grade) FROM en.SC);

-- 3. 相关子查询：查询每个学生超过自己平均成绩的课程
SELECT Sno, Cno, Grade
FROM en.SC sc1
WHERE Grade > (
    SELECT AVG(Grade) 
    FROM en.SC sc2 
    WHERE sc2.Sno = sc1.Sno
);

-- 4. 带有EXISTS的子查询：查询没有选课的学生
SELECT Sno, Sname
FROM en.Student s
WHERE NOT EXISTS (
    SELECT 1 FROM en.SC WHERE Sno = s.Sno
);
```

#### 步骤3：集合查询
```sql
-- 1. 并集查询：查询选修了81001或81007课程的学生
SELECT Sno FROM en.SC WHERE Cno = '81001'
UNION
SELECT Sno FROM en.SC WHERE Cno = '81007';

-- 2. 交集查询：查询既选修81001又选修81002的学生
SELECT Sno FROM en.SC WHERE Cno = '81001'
INTERSECT
SELECT Sno FROM en.SC WHERE Cno = '81002';

-- 3. 差集查询：查询选修了81001但没有选修81002的学生
SELECT Sno FROM en.SC WHERE Cno = '81001'
EXCEPT
SELECT Sno FROM en.SC WHERE Cno = '81002';
```

#### 步骤4：复杂数据操作
```sql
-- 1. 基于子查询的更新：将计算机专业学生的所有成绩提高5%
UPDATE en.SC
SET Grade = LEAST(Grade * 1.05, 100)
WHERE Sno IN (
    SELECT Sno FROM en.Student WHERE Smajor = '计算机科学与技术'
);

-- 2. 基于子查询的删除：删除没有选课的学生记录
DELETE FROM en.Student
WHERE Sno NOT IN (SELECT DISTINCT Sno FROM en.SC);

-- 3. 插入选课数据（带检查）
INSERT INTO en.SC (Sno, Cno, Grade, Semester, Teachingclass)
SELECT '20180005', '81007', NULL, '20203', '81007-01'
WHERE EXISTS (
    SELECT 1 FROM en.Student WHERE Sno = '20180005'
) AND EXISTS (
    SELECT 1 FROM en.Course WHERE Cno = '81007'
);
```

### 3.3 实验思考题
1. IN和EXISTS在子查询中有什么区别？哪种情况下使用哪种更好？
2. 相关子查询和非相关子查询的执行机制有什么不同？
3. UNION和UNION ALL有什么区别？在什么情况下应该使用UNION ALL？

---

## 实验四：综合应用与性能分析

### 4.1 实验目的
1. 综合运用SQL解决复杂查询问题
2. 学习使用视图简化复杂查询
3. 理解索引对查询性能的影响
4. 掌握基本的查询性能分析方法

### 4.2 实验内容

#### 步骤1：创建复杂查询视图
```sql
-- 1. 创建学生成绩详情视图
CREATE VIEW en.StudentGradeDetail AS
SELECT s.Sno, s.Sname, s.Smajor, c.Cno, c.Cname, sc.Grade, sc.Semester
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
JOIN en.Course c ON sc.Cno = c.Cno;

-- 2. 创建课程先修关系视图
CREATE VIEW en.CoursePrerequisite AS
SELECT c1.Cno AS Course_No, c1.Cname AS Course_Name,
       c2.Cno AS Prereq_No, c2.Cname AS Prereq_Name
FROM en.Course c1
LEFT JOIN en.Course c2 ON c1.Cpno = c2.Cno;

-- 3. 使用视图进行查询
SELECT * FROM en.StudentGradeDetail WHERE Grade > 90;
SELECT * FROM en.CoursePrerequisite ORDER BY Course_No;
```

#### 步骤2：创建索引优化查询性能
```sql
-- 1. 在常用查询条件上创建索引
CREATE INDEX idx_student_major ON en.Student(Smajor);
CREATE INDEX idx_sc_sno ON en.SC(Sno);
CREATE INDEX idx_sc_cno ON en.SC(Cno);
CREATE INDEX idx_sc_semester ON en.SC(Semester);
CREATE INDEX idx_course_cname ON en.Course(Cname);

-- 2. 查看索引信息
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE schemaname = 'en';

-- 3. 分析查询执行计划
EXPLAIN ANALYZE
SELECT s.Sname, c.Cname, sc.Grade
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
JOIN en.Course c ON sc.Cno = c.Cno
WHERE s.Smajor = '计算机科学与技术' AND sc.Grade > 80;

-- 4. 对比有无索引的查询性能
-- 删除索引后重新测试
DROP INDEX IF EXISTS idx_student_major;
EXPLAIN ANALYZE
SELECT s.Sname, c.Cname, sc.Grade
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
JOIN en.Course c ON sc.Cno = c.Cno
WHERE s.Smajor = '计算机科学与技术' AND sc.Grade > 80;

-- 重新创建索引
CREATE INDEX idx_student_major ON en.Student(Smajor);
```

#### 步骤3：综合查询练习
```sql
-- 1. 查询每个专业的平均成绩
SELECT s.Smajor, ROUND(AVG(sc.Grade), 2) AS Avg_Grade
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
WHERE sc.Grade IS NOT NULL
GROUP BY s.Smajor
ORDER BY Avg_Grade DESC;

-- 2. 查询每门课程的选课人数和平均成绩
SELECT c.Cno, c.Cname, COUNT(sc.Sno) AS Student_Count,
       ROUND(AVG(sc.Grade), 2) AS Avg_Grade
FROM en.Course c
LEFT JOIN en.SC sc ON c.Cno = sc.Cno
GROUP BY c.Cno, c.Cname
ORDER BY Student_Count DESC;

-- 3. 查询成绩优秀的学生（平均成绩≥90）
SELECT s.Sno, s.Sname, ROUND(AVG(sc.Grade), 2) AS Avg_Grade
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
GROUP BY s.Sno, s.Sname
HAVING AVG(sc.Grade) >= 90;

-- 4. 查询有不及格课程的学生
SELECT DISTINCT s.Sno, s.Sname
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
WHERE sc.Grade < 60 OR sc.Grade IS NULL;
```

#### 步骤4：事务处理
```sql
-- 1. 开始事务
BEGIN TRANSACTION;

-- 2. 插入新课程
INSERT INTO en.Course (Cno, Cname, Ccredit, Cpno)
VALUES ('81009', '人工智能基础', 3, '81002');

-- 3. 插入选课记录
INSERT INTO en.SC (Sno, Cno, Grade, Semester, Teachingclass)
SELECT Sno, '81009', NULL, '20231', '81009-01'
FROM en.Student 
WHERE Smajor = '计算机科学与技术';

-- 4. 提交事务
COMMIT;

-- 5. 验证插入结果
SELECT * FROM en.Course WHERE Cno = '81009';
SELECT COUNT(*) FROM en.SC WHERE Cno = '81009';
```

#### 步骤5：数据控制语句（GRANT/REVOKE）
```sql
-- 1. 创建测试用户
CREATE USER student_user WITH PASSWORD 'student123';
CREATE USER teacher_user WITH PASSWORD 'teacher123';

-- 2. 授权操作
-- 授予学生用户查询和插入权限
GRANT SELECT, INSERT ON en.Student TO student_user;
GRANT SELECT ON en.Course TO student_user;
GRANT SELECT, INSERT ON en.SC TO student_user;

-- 授予教师用户完整权限
GRANT ALL PRIVILEGES ON en.Student TO teacher_user;
GRANT ALL PRIVILEGES ON en.Course TO teacher_user;
GRANT ALL PRIVILEGES ON en.SC TO teacher_user;

-- 3. 查看权限信息
SELECT grantee, privilege_type, table_name 
FROM information_schema.table_privileges 
WHERE table_schema = 'en' AND table_name IN ('student', 'course', 'sc');

-- 4. 撤销权限
REVOKE DELETE ON en.SC FROM student_user;
REVOKE ALL PRIVILEGES ON en.Student FROM teacher_user;

-- 5. 清理测试用户
DROP USER IF EXISTS student_user;
DROP USER IF EXISTS teacher_user;
```

### 4.3 实验思考题
1. 视图和表有什么区别？使用视图有什么优点？
2. 在哪些列上创建索引最能提高查询性能？为什么？
3. 事务的ACID特性在示例中是如何体现的？
4. 分析执行计划时，哪些操作是成本较高的？如何优化？

---

## 实验报告要求

### 1. 实验环境说明
- 操作系统版本
- PostgreSQL版本
- 数据库名称和模式

### 2. 实验过程记录
- 每个实验步骤的执行结果
- 遇到的错误和解决方法
- 关键SQL语句和输出结果

### 3. 实验结果分析
- 对每个思考题的解答
- 查询性能分析结果
- 实验中的收获和体会

### 4. 实验总结
- 掌握的知识点
- 存在的问题和不足
- 下一步学习计划

### 5. 附录
- 完整的SQL脚本
- 重要的查询输出截图

---

## 实验五：视图的完整操作

### 5.1 实验目的
1. 掌握视图的创建、修改、删除操作
2. 理解视图与基本表的区别
3. 学习通过视图进行数据操作
4. 掌握视图的权限管理

### 5.2 实验内容

#### 步骤1：创建视图
```sql
-- 1. 创建简单视图
CREATE VIEW en.StudentView AS
SELECT Sno, Sname, Smajor FROM en.Student;

-- 2. 创建复杂视图（带计算字段）
CREATE VIEW en.StudentGradeView AS
SELECT s.Sno, s.Sname, s.Smajor, 
       COUNT(sc.Cno) AS Course_Count,
       ROUND(AVG(sc.Grade), 2) AS Avg_Grade
FROM en.Student s
LEFT JOIN en.SC sc ON s.Sno = sc.Sno
GROUP BY s.Sno, s.Sname, s.Smajor;

-- 3. 创建带条件的视图
CREATE VIEW en.ExcellentStudentView AS
SELECT s.Sno, s.Sname, s.Smajor, AVG(sc.Grade) AS Avg_Grade
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
WHERE sc.Grade IS NOT NULL
GROUP BY s.Sno, s.Sname, s.Smajor
HAVING AVG(sc.Grade) >= 85;
```

#### 步骤2：查询视图
```sql
-- 1. 查询简单视图
SELECT * FROM en.StudentView WHERE Smajor = '计算机科学与技术';

-- 2. 查询复杂视图
SELECT * FROM en.StudentGradeView ORDER BY Avg_Grade DESC;

-- 3. 查询优秀学生视图
SELECT * FROM en.ExcellentStudentView;
```

#### 步骤3：修改视图
```sql
-- 1. 使用CREATE OR REPLACE修改视图
CREATE OR REPLACE VIEW en.StudentView AS
SELECT Sno, Sname, Smajor, Ssex FROM en.Student;

-- 2. 修改视图定义
CREATE OR REPLACE VIEW en.StudentGradeView AS
SELECT s.Sno, s.Sname, s.Smajor, 
       COUNT(sc.Cno) AS Course_Count,
       ROUND(AVG(sc.Grade), 2) AS Avg_Grade,
       MAX(sc.Grade) AS Max_Grade,
       MIN(sc.Grade) AS Min_Grade
FROM en.Student s
LEFT JOIN en.SC sc ON s.Sno = sc.Sno
GROUP BY s.Sno, s.Sname, s.Smajor;
```

#### 步骤4：通过视图操作数据
```sql
-- 1. 通过视图插入数据（仅适用于简单视图）
INSERT INTO en.StudentView (Sno, Sname, Smajor, Ssex)
VALUES ('20180009', '测试学生', '软件工程', '男');

-- 2. 通过视图更新数据
UPDATE en.StudentView SET Smajor = '人工智能' 
WHERE Sno = '20180009';

-- 3. 通过视图删除数据
DELETE FROM en.StudentView WHERE Sno = '20180009';
```

#### 步骤5：视图权限管理
```sql
-- 1. 创建测试用户
CREATE USER view_user WITH PASSWORD 'view123';

-- 2. 授予视图权限
GRANT SELECT ON en.StudentView TO view_user;
GRANT SELECT ON en.StudentGradeView TO view_user;

-- 3. 查看视图权限
SELECT grantee, privilege_type, table_name 
FROM information_schema.table_privileges 
WHERE table_schema = 'en' AND table_name LIKE '%view%';

-- 4. 撤销视图权限
REVOKE SELECT ON en.StudentView FROM view_user;

-- 5. 清理测试用户
DROP USER IF EXISTS view_user;
```

#### 步骤6：删除视图
```sql
-- 1. 删除单个视图
DROP VIEW IF EXISTS en.StudentView;

-- 2. 删除多个视图
DROP VIEW IF EXISTS en.StudentGradeView, en.ExcellentStudentView;

-- 3. 查看剩余视图
SELECT viewname FROM pg_views WHERE schemaname = 'en';
```

### 5.3 实验思考题
1. 视图和基本表有什么区别？视图的优点是什么？
2. 什么情况下可以通过视图进行数据修改？
3. 视图的权限管理与表的权限管理有什么不同？
4. 使用CREATE OR REPLACE VIEW有什么好处？

---

## 实验扩展练习

### 扩展练习1：数据备份与恢复
```sql
-- 1. 备份数据库
pg_dump -U postgres -h localhost -p 5432 db_cms_dev > backup.sql

-- 2. 恢复数据库
psql -U postgres -h localhost -p 5432 db_cms_dev < backup.sql
```

### 扩展练习2：高级查询挑战
```sql
-- 1. 查询每个学生选修课程的总学分
SELECT s.Sno, s.Sname, SUM(c.Ccredit) AS Total_Credits
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
JOIN en.Course c ON sc.Cno = c.Cno
WHERE sc.Grade >= 60 OR sc.Grade IS NULL
GROUP BY s.Sno, s.Sname
ORDER BY Total_Credits DESC;

-- 2. 查询课程依赖关系（递归查询）
WITH RECURSIVE course_deps AS (
    SELECT Cno, Cname, Cpno, 0 AS level
    FROM en.Course
    WHERE Cpno IS NULL
    UNION ALL
    SELECT c.Cno, c.Cname, c.Cpno, cd.level + 1
    FROM en.Course c
    JOIN course_deps cd ON c.Cpno = cd.Cno
)
SELECT * FROM course_deps ORDER BY level, Cno;
```

### 扩展练习3：性能优化实践
```sql
-- 1. 创建复合索引
CREATE INDEX idx_sc_sno_cno ON en.SC(Sno, Cno);

-- 2. 分析查询计划
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT s.Sname, AVG(sc.Grade) as avg_grade
FROM en.Student s
JOIN en.SC sc ON s.Sno = sc.Sno
GROUP BY s.Sno, s.Sname
HAVING AVG(sc.Grade) > 85;
```

**注意事项**：
1. 实验前请备份重要数据
2. 每个实验步骤完成后请验证结果
3. 遇到错误时仔细阅读错误信息并分析原因
4. 实验报告要求实事求是，严禁抄袭
5. 建议使用版本控制工具（如Git）管理实验代码
6. 实验过程中注意观察SQL执行时间和资源消耗

**学习建议**：
- 多练习不同类型的查询，理解SQL的执行逻辑
- 关注查询性能，学会使用EXPLAIN分析执行计划
- 理解数据库设计原则，掌握规范化理论
- 实践事务处理，理解ACID特性
