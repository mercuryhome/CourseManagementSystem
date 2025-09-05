-- =====================================================
-- 学生选课数据库系统
-- 基于王珊《数据库系统概论》第6版 图2-1
-- PostgreSQL 17版本
-- 优化版本：增强PRIMARY KEY和UNIQUE约束
-- =====================================================

-- 创建数据库
-- 注意：在PostgreSQL中，通常需要先连接到postgres数据库，然后创建新数据库
-- 方案1：使用默认排序规则（推荐）
-- CREATE DATABASE db_cms
--     WITH 
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- 方案2：如果需要中文排序规则，使用template0模板
-- CREATE DATABASE db_cms
--     WITH 
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'zh_CN.UTF-8'
--     LC_CTYPE = 'zh_CN.UTF-8'
--     TEMPLATE = template0
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1;

-- 连接到新创建的数据库后执行以下语句

-- 删除已存在的表（如果存在）
-- 注意：删除顺序要考虑外键约束，先删除子表，再删除父表
DROP TABLE IF EXISTS SC CASCADE;
DROP TABLE IF EXISTS TeachingClass CASCADE;
DROP TABLE IF EXISTS Course CASCADE;
DROP TABLE IF EXISTS Student CASCADE;

-- 创建学生表
CREATE TABLE Student (
    Sno VARCHAR(8) PRIMARY KEY,
    Sname VARCHAR(20) NOT NULL,
    Ssex CHAR(1) NOT NULL CHECK (Ssex IN ('男', '女')),
    Sbirthdate DATE,
    Smajor VARCHAR(50),
    -- 添加UNIQUE约束：学生姓名在同一专业内应该唯一
    CONSTRAINT uk_student_name_major UNIQUE (Sname, Smajor)
);

-- 为Student表添加注释
COMMENT ON TABLE Student IS '学生信息表';
COMMENT ON COLUMN Student.Sno IS '学号，主键，8位字符串';
COMMENT ON COLUMN Student.Sname IS '学生姓名，不能为空';
COMMENT ON COLUMN Student.Ssex IS '性别，只能是男或女';
COMMENT ON COLUMN Student.Sbirthdate IS '出生日期';
COMMENT ON COLUMN Student.Smajor IS '主修专业';

-- 创建课程表
CREATE TABLE Course (
    Cno VARCHAR(5) PRIMARY KEY,
    Cname VARCHAR(50) NOT NULL UNIQUE, -- 课程名称应该唯一
    Ccredit INTEGER NOT NULL CHECK (Ccredit > 0),
    Cpno VARCHAR(5)
);

-- 为Course表添加注释
COMMENT ON TABLE Course IS '课程信息表';
COMMENT ON COLUMN Course.Cno IS '课程号，主键，5位字符串';
COMMENT ON COLUMN Course.Cname IS '课程名称，不能为空且唯一';
COMMENT ON COLUMN Course.Ccredit IS '学分，必须大于0';
COMMENT ON COLUMN Course.Cpno IS '先修课程号，自引用外键';

-- 添加Course表的外键约束（自引用）
ALTER TABLE Course 
ADD CONSTRAINT fk_course_prerequisite 
FOREIGN KEY (Cpno) REFERENCES Course(Cno);

-- 创建选课表（学生-课程关系表）
CREATE TABLE SC (
    Sno VARCHAR(8) NOT NULL,
    Cno VARCHAR(5) NOT NULL,
    Grade INTEGER CHECK (Grade >= 0 AND Grade <= 100),
    Semester VARCHAR(5) NOT NULL CHECK (Semester ~ '^[0-9]{4}[12]$'), -- 格式：YYYY1或YYYY2
    Teachingclass VARCHAR(10),
    -- 复合主键：确保同一学生在同一学期不能重复选同一门课
    PRIMARY KEY (Sno, Cno, Semester),
    -- 添加UNIQUE约束：同一学生在同一学期同一教学班只能选一门课
    CONSTRAINT uk_sc_student_teachingclass UNIQUE (Sno, Teachingclass, Semester)
);

-- 为SC表添加注释
COMMENT ON TABLE SC IS '学生选课关系表';
COMMENT ON COLUMN SC.Sno IS '学号，外键引用Student.Sno';
COMMENT ON COLUMN SC.Cno IS '课程号，外键引用Course.Cno';
COMMENT ON COLUMN SC.Grade IS '成绩，0-100分';
COMMENT ON COLUMN SC.Semester IS '开课学期，格式：YYYYX（X为1或2）';
COMMENT ON COLUMN SC.Teachingclass IS '教学班编号';

-- 添加SC表的外键约束
ALTER TABLE SC 
ADD CONSTRAINT fk_sc_student 
FOREIGN KEY (Sno) REFERENCES Student(Sno);

ALTER TABLE SC 
ADD CONSTRAINT fk_sc_course 
FOREIGN KEY (Cno) REFERENCES Course(Cno);

-- 创建教学班表（新增表，用于管理教学班信息）
CREATE TABLE TeachingClass (
    Teachingclass VARCHAR(10) PRIMARY KEY,
    Cno VARCHAR(5) NOT NULL,
    Semester VARCHAR(5) NOT NULL CHECK (Semester ~ '^[0-9]{4}[12]$'),
    Teacher VARCHAR(20),
    MaxStudents INTEGER DEFAULT 50 CHECK (MaxStudents > 0),
    -- 同一课程在同一学期可以有多个教学班，但教学班编号必须唯一
    CONSTRAINT uk_teachingclass_course_semester UNIQUE (Cno, Semester, Teachingclass)
);

-- 为TeachingClass表添加注释
COMMENT ON TABLE TeachingClass IS '教学班信息表';
COMMENT ON COLUMN TeachingClass.Teachingclass IS '教学班编号，主键';
COMMENT ON COLUMN TeachingClass.Cno IS '课程号，外键引用Course.Cno';
COMMENT ON COLUMN TeachingClass.Semester IS '开课学期，格式：YYYYX（X为1或2）';
COMMENT ON COLUMN TeachingClass.Teacher IS '授课教师';
COMMENT ON COLUMN TeachingClass.MaxStudents IS '最大学生数，默认50人';

-- 添加TeachingClass表的外键约束
ALTER TABLE TeachingClass 
ADD CONSTRAINT fk_teachingclass_course 
FOREIGN KEY (Cno) REFERENCES Course(Cno);

-- 修改SC表，添加对TeachingClass的外键约束
ALTER TABLE SC 
ADD CONSTRAINT fk_sc_teachingclass 
FOREIGN KEY (Teachingclass) REFERENCES TeachingClass(Teachingclass);

-- 插入示例数据

-- 插入学生数据
INSERT INTO Student (Sno, Sname, Ssex, Sbirthdate, Smajor) VALUES
('20180001', '李勇', '男', '2000-03-08', '信息安全'),
('20180002', '刘晨', '女', '1999-09-01', '计算机科学与技术'),
('20180003', '王敏', '女', '2001-08-01', '信息管理与信息系统'),
('20180004', '张立', '男', '2000-01-08', '数据科学与大数据技术'),
('20180005', '陈新奇', '男', '2001-11-01', '信息安全'),
('20180006', '赵明', '男', '2000-06-12', '计算机科学与技术'),
('20180007', '王佳佳', '女', '2001-12-07', '信息管理与信息系统');

-- 插入课程数据
INSERT INTO Course (Cno, Cname, Ccredit, Cpno) VALUES
('81001', '程序设计基础与C语言', 4, NULL),
('81002', '数据结构', 4, '81001'),
('81003', '数据库系统概论', 3, '81002'),
('81004', '信息系统概论', 3, '81003'),
('81005', '操作系统', 4, '81001'),
('81006', 'Python语言', 3, '81002'),
('81007', '离散数学', 3, NULL),
('81008', '大数据技术概论', 3, '81003');

-- 插入教学班数据
INSERT INTO TeachingClass (Teachingclass, Cno, Semester, Teacher, MaxStudents) VALUES
('81001-01', '81001', '20192', '张教授', 45),
('81001-02', '81001', '20192', '李教授', 50),
('81002-01', '81002', '20201', '王教授', 40),
('81002-02', '81002', '20201', '陈教授', 45),
('81003-01', '81003', '20202', '刘教授', 35),
('81003-02', '81003', '20202', '赵教授', 40);

-- 插入选课数据
INSERT INTO SC (Sno, Cno, Grade, Semester, Teachingclass) VALUES
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

-- 创建索引以提高查询性能
-- 基于PRIMARY KEY的索引会自动创建，这里创建额外的索引
CREATE INDEX idx_student_major ON Student(Smajor);
CREATE INDEX idx_student_birthdate ON Student(Sbirthdate);
CREATE INDEX idx_course_credit ON Course(Ccredit);
CREATE INDEX idx_course_prerequisite ON Course(Cpno);
CREATE INDEX idx_sc_grade ON SC(Grade);
CREATE INDEX idx_sc_semester ON SC(Semester);
CREATE INDEX idx_sc_student_semester ON SC(Sno, Semester);
CREATE INDEX idx_teachingclass_course ON TeachingClass(Cno);
CREATE INDEX idx_teachingclass_semester ON TeachingClass(Semester);
CREATE INDEX idx_teachingclass_teacher ON TeachingClass(Teacher);

-- 创建部分索引（针对有成绩的记录）
CREATE INDEX idx_sc_grade_not_null ON SC(Grade) WHERE Grade IS NOT NULL;

-- 创建唯一索引（确保数据完整性）
CREATE UNIQUE INDEX idx_student_sno ON Student(Sno);
CREATE UNIQUE INDEX idx_course_cno ON Course(Cno);
CREATE UNIQUE INDEX idx_course_cname ON Course(Cname);

-- 验证数据完整性
-- 查看表结构和数据
SELECT 'Student表数据' as table_name, COUNT(*) as record_count FROM Student
UNION ALL
SELECT 'Course表数据' as table_name, COUNT(*) as record_count FROM Course
UNION ALL
SELECT 'TeachingClass表数据' as table_name, COUNT(*) as record_count FROM TeachingClass
UNION ALL
SELECT 'SC表数据' as table_name, COUNT(*) as record_count FROM SC;

-- 查看主键约束
SELECT 
    tc.table_name, 
    kcu.column_name,
    tc.constraint_type
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
    AND tc.table_schema = 'public'
ORDER BY tc.table_name, tc.constraint_type;

-- 查看外键约束
SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- 验证约束的有效性
-- 检查是否有违反UNIQUE约束的数据
SELECT 'Student表姓名专业唯一性检查' as check_name,
       COUNT(*) as duplicate_count
FROM (
    SELECT Sname, Smajor, COUNT(*)
    FROM Student
    GROUP BY Sname, Smajor
    HAVING COUNT(*) > 1
) t
UNION ALL
SELECT 'Course表课程名唯一性检查' as check_name,
       COUNT(*) as duplicate_count
FROM (
    SELECT Cname, COUNT(*)
    FROM Course
    GROUP BY Cname
    HAVING COUNT(*) > 1
) t;
