-- 第3章 关系数据库标准语言SQL

-- 3.1 SQL概述
    -- 表3.2 SQL 9个动词
        -- 数 据 定 义:  CREATE, DROP, ALTER
        -- 数 据 查 询:  SELECT
        -- 数 据 操 纵:  INSERT, UPDATE, DELETE
        -- 数 据 控 制:  GRANT, REVOKE

-- 3.2 表3.3 SQL 数据定义语句
    --  操 作 对 象            创 建           删 除          修 改
    --  数 据 库 模 式    CREATE SCHEMA       DROP SCHEMA    * SQL 标准 无修改语句
    --  表              CREATE TABLE         DROP TABLE     ALTER TABLE
    --  视 图           CREATE VIEW          DROP VIEW      * CREATE OR REPLACE VIEW 
    --  索 引          CREATE INDEX          DROP INDEX      ALTER INDEX

-- 3.2 数据库对象命名机制的层次结构
    -- 数据库实例instance：一组进程和内存的集合
        --  mac osx 启动/停止/重启postgresql 17服务
            -- 启动：brew services start postgresql@17
            -- 停止：brew services stop postgresql@17
            -- 重启：brew services restart postgresql@17
        --  mac osx/linux  shell$  lsof -i:5432
        --  mac osx/linux  shell$  ps -ef | grep postgres
        --  mac osx 安装pstree: brew install pstree
        --  查看postgresql 进程树：lsof -i:5432 | grep LISTEN | awk '{print $2}' | xargs pstree -p

    -- 实例instance --> 数据库database -> 模式schema -> 表table\视图view\索引index
       -- 例子： db_cms -> public -> student, course, sc
       -- 例子： select * from public.student;

    -- postgres 客户端工具 psql 连接数据库
        -- 需求： 用 psql 以 postgres 用户身份 访问postgres实例（主机localhost 端口port 5432） 数据库 db_cms 
           -- psql -U postgres -h localhost -p 5432 -d db_cms
           -- psql postgresql://postgres:***@localhost:5432/db_cms
               -- 数据库连接串格式：postgresql://username:password@host:port/database
        
        -- 注意：PostgreSQL 17安装后可能没有默认的postgres用户，需要手动创建
        -- 1. 无用户连接：psql -h localhost -d postgres
        -- 2. 创建用户：CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'your_password';
        -- 3. 验证用户：\du

-- 3.2.0 数据库， 模式的定义和删除； 设置模式搜索路径
    --  任务：进入psql, 创建两个数据库 db_cms_dev, db_temp;  删除 db_temp 
        -- psql -U postgres -h localhost -p 5432 -d postgres
            -- 创建测试数据库 db_cms_dev, db_temp
                create database db_cms_dev;
                create database db_temp; 
            -- 查看创建结果, \l+  添加加号可以查看更多详情
                -- postgres=# \l
                -- postgres=# \l+
            -- 连接数据库（或称打开数据库）
                -- postgres=# \c db_cms_dev;
                -- postgres=# \c db_temp;
            --  删除数据库 db_temp, 注意不能删除当前打开的数据库： ERROR:  cannot drop the currently open database
                drop database db_temp;  
            -- 退出psql
                -- postgres=# \q

    -- 任务： 进入psql，在 db_cms_dev 数据库下 创建英文系模式 en, 中文系模式 cn, 临时模式 temp; 删除模式 temp
        -- psql -U postgres -h localhost -p 5432 -d db_cms_dev
            -- 查看连接信息
               -- db_cms_dev=# \c
            -- 创建英文系模式 en, 中文系模式 cn
               create schema en;
               create schema cn;
               create schema temp;
            -- 查看模式schema列表 (==命名空间 namespace）
               -- db_cms_dev=# \dn
               -- db_cms_dev=# \dn+
               -- db_cms_dev=# \dn+ temp
            -- 删除模式 temp
               db_cms_dev=# drop schema temp;

    -- 任务： 授权当前用户(postgres) 可在模式 en, cn 下创建（CREATE）数据库对象  
        -- psql -U postgres -h localhost -p 5432 -d db_cms_dev
            -- 查看当前用户是否获得授权
                SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('en', 'cn');
            -- 授权当前用户(postgres) 可在模式 en, cn 下创建（CREATE）数据库对象  
                GRANT CREATE ON SCHEMA en,cn TO current_user;
            -- 查看当前用户是否获得授权
                SELECT schema_name FROM information_schema.schemata WHERE schema_name IN ('en', 'cn');

    -- 任务： 设置模式搜索路径 - 两种方法（临时，永久）
        -- psql -U postgres -h localhost -p 5432 -d db_cms_dev
            -- 查看当前模式搜索路径
               -- db_cms_dev=# show search_path;
            -- 设置模式搜索路径至： cn, en, public.  SET设置方法仅在当前连接会话生效，退出会话即失效。
               -- db_cms_dev=# set search_path to cn,en,public;
               -- db_cms_dev=# show search_path;
            -- 修改用户/角色 的搜索路径至 en, cn, public
               -- db_cms_dev=# alter role current_user set search_path to en,en,public;
               -- db_cms_dev=# show search_path;    # 注意观察 修改是否生效？
            -- 退出 \q, 重新进入 , 查看搜索路径设置是否生效
               -- db_cms_dev=# show search_path;    # 注意观察 修改是否生效

-- 3.3 数据的定义

    -- 进入以下psql环境：  psql -U postgres -h localhost -p 5432 -d db_cms_dev

    -- 任务 例3.3 

        -- # \c    查看连接信息确认当前所在的用户身份及数据库名称  
        -- # show search_path ， 查看模式搜索路径

            -- 创建学生表（注意：需要在en模式下创建）
            CREATE TABLE en.Student (
                Sno CHAR(8) PRIMARY KEY,
                Sname VARCHAR(20) UNIQUE, 
                Ssex CHAR(6),
                Sbirthdate DATE,
                Smajor VARCHAR(40)
            );

        -- 表3.4 SQL 标准常⽤的数据类 型

            -- 创建课程表
            CREATE TABLE en.Course (
                Cno VARCHAR(5) PRIMARY KEY,
                Cname VARCHAR(40) NOT NULL,
                Ccredit SMALLINT NOT NULL CHECK (Ccredit > 0),
                Cpno VARCHAR(5),
                FOREIGN KEY (Cpno) REFERENCES en.Course(Cno)
            );

            -- 创建选课表（学生-课程关系表）
            CREATE TABLE en.SC (
                Sno CHAR(8) NOT NULL,  -- 修改为CHAR(8)与Student表保持一致
                Cno VARCHAR(5) NOT NULL,
                Grade SMALLINT CHECK (Grade >= 0 AND Grade <= 100),
                Semester VARCHAR(5) NOT NULL CHECK (Semester ~ '^[0-9]{4}[12]$'), -- 格式：YYYY1或YYYY2
                Teachingclass VARCHAR(8),
                -- 复合主键：确保同一学生在同一学期不能重复选同一门课
                PRIMARY KEY (Sno, Cno, Semester),
                FOREIGN KEY (Sno) REFERENCES en.Student(Sno),
                FOREIGN KEY (Cno) REFERENCES en.Course(Cno),
                -- 添加UNIQUE约束：同一学生在同一学期同一教学班只能选一门课
                CONSTRAINT uk_sc_student_teachingclass UNIQUE (Sno, Teachingclass, Semester)
            );

    -- 3.4 数据的插入
        -- 任务：例3.71 (p108) 插入示例数据

            -- 插入学生数据
            INSERT INTO en.Student (Sno, Sname, Ssex, Sbirthdate, Smajor) VALUES
            ('20180001', '李勇', '男', '2000-03-08', '信息安全'),
            ('20180002', '刘晨', '女', '1999-09-01', '计算机科学与技术'),
            ('20180003', '王敏', '女', '2001-08-01', '信息管理与信息系统'),
            ('20180004', '张立', '男', '2000-01-08', '数据科学与大数据技术'),
            ('20180005', '陈新奇', '男', '2001-11-01', '信息安全'),
            ('20180006', '赵明', '男', '2000-06-12', '计算机科学与技术'),
            ('20180007', '王佳佳', '女', '2001-12-07', '信息管理与信息系统');

            -- 插入课程数据
            INSERT INTO en.Course (Cno, Cname, Ccredit, Cpno) VALUES
            ('81001', '程序设计基础与C语言', 4, NULL),
            ('81002', '数据结构', 4, '81001'),
            ('81003', '数据库系统概论', 3, '81002'),
            ('81004', '信息系统概论', 3, '81003'),
            ('81005', '操作系统', 4, '81001'),
            ('81006', 'Python语言', 3, '81002'),
            ('81007', '离散数学', 3, NULL),
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

    -- 3.3 数据查询  - select (重点)
    -- 3.3.1 单表查询
        -- 任务： 3.16 实例
            -- 查询学生表所有列
            SELECT * FROM en.Student;
            -- 查询学生表学号和姓名
            SELECT Sno, Sname FROM en.Student;

        -- 实例3.16 ~ 3.50 (p81 ~ p91)
        
        -- 3.3.2 更多单表查询示例
            -- 条件查询
            SELECT Sname, Smajor FROM en.Student WHERE Smajor = '计算机科学与技术';
            
            -- 模糊查询
            SELECT * FROM en.Student WHERE Sname LIKE '李%';
            
            -- 范围查询
            SELECT * FROM en.SC WHERE Grade BETWEEN 80 AND 90;
            
            -- 排序查询
            SELECT Sname, Sbirthdate FROM en.Student ORDER BY Sbirthdate DESC;
            
            -- 分组查询
            SELECT Smajor, COUNT(*) FROM en.Student GROUP BY Smajor;
            
            -- 空值查询
            SELECT * FROM en.SC WHERE Grade IS NULL;

    -- 3.5 数据更新操作
        -- 更新数据
        UPDATE en.Student SET Smajor = '数据科学与大数据技术' WHERE Sno = '20180003';
        
        -- 删除数据
        DELETE FROM en.Student WHERE Sno = '20180007';

    -- 3.6 表结构修改（ALTER TABLE）
        -- 添加列
        ALTER TABLE en.Student ADD COLUMN Sphone VARCHAR(15);
        
        -- 修改列类型
        ALTER TABLE en.Student ALTER COLUMN Sname TYPE VARCHAR(30);
        
        -- 删除列
        ALTER TABLE en.Student DROP COLUMN Sphone;

    -- 3.7 视图操作
        -- 创建视图
        CREATE VIEW en.StudentView AS
        SELECT Sno, Sname, Smajor FROM en.Student;
        
        -- 查询视图
        SELECT * FROM en.StudentView WHERE Smajor = '计算机科学与技术';
        
        -- 删除视图
        DROP VIEW en.StudentView;

    -- 3.8 索引操作
        -- 创建索引
        CREATE INDEX idx_student_major ON en.Student(Smajor);
        CREATE INDEX idx_sc_sno ON en.SC(Sno);
        
        -- 删除索引
        DROP INDEX idx_student_major;

    -- 3.9 数据控制语句
        -- 创建用户
        CREATE USER student_user WITH PASSWORD 'student123';
        
        -- 授权
        GRANT SELECT ON en.Student TO student_user;
        
        -- 撤销权限
        REVOKE SELECT ON en.Student FROM student_user;
        
        -- 删除用户
        DROP USER student_user;

-- 补充资料 第3章 SQL实验指导：ch03/ch03-sql-lab.md