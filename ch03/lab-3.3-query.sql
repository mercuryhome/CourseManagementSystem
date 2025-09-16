/*
 * 王珊《数据库系统概论》第6版 第3.3章 数据查询
 * 实验环境：PostgreSQL 17
 * 数据库：db_cms_dev
 * 模式：en
 * 
 * PostgreSQL 17 兼容性说明：
 * 1. 支持标准SQL查询语法
 * 2. 增强的JSON函数支持
 * 3. 改进的查询优化器性能
 * 4. 支持窗口函数和CTE
 */

-- ===========================================
-- 3.3.1 单表查询
-- ===========================================

-- 3.3.1.1 选择表中的若干列
-- 例3.16 查询全体学生的学号与姓名
SELECT sno, sname 
FROM en.student;

-- 例3.17 查询全体学生的姓名、学号、主修专业
SELECT sname, sno, smajor 
FROM en.student;

-- 例3.18 查询全体学生的详细记录
SELECT * 
FROM en.student;

-- 3.3.1.2 选择表中的若干元组
-- 例3.19 查询所有选修过课程的学生学号
SELECT DISTINCT sno 
FROM en.sc;

-- 例3.19 查询全体学生的姓名及其年龄
-- 方法1：使用EXTRACT函数计算年龄
SELECT sname, 
       EXTRACT(YEAR FROM age(current_date, sbirthdate)) AS sage 
FROM en.student;

-- 方法2：使用date_part函数计算年龄
SELECT sname, 
       date_part('year', age(current_date, sbirthdate)) AS sage 
FROM en.student;

-- 方法3：使用age函数并格式化输出
SELECT sname, 
       age(current_date, sbirthdate) AS age_interval 
FROM en.student;

-- 例3.20 查询考试成绩不及格的学生学号
SELECT DISTINCT sno 
FROM en.sc 
WHERE grade < 60;

-- 例3.20.1 查询全体学生的姓名、出生日期和主修专业
SELECT sname, sbirthdate, smajor
FROM en.student;

-- 例3.21 查询选修了课程的学生学号
SELECT DISTINCT sno
FROM en.sc;

-- 例3.22 查询主修计算机科学与技术专业全体学生的姓名
SELECT sname
FROM en.student
WHERE smajor = '计算机科学与技术';
-- 注意：字符串常数要用单引号(英文符号)括起来

-- 例3.23 查询2000年及2000年后出生的所有学生的姓名及其性别
SELECT sname, ssex
FROM en.student
WHERE EXTRACT(YEAR FROM sbirthdate) >= 2000;
-- 函数EXTRACT(YEAR FROM sbirthdate)用于从出生日期中抽取出年份

-- 例3.24 查询考试成绩不及格的学生学号
SELECT DISTINCT sno 
FROM en.sc
WHERE grade < 60;

-- 例3.25 查询年龄在20~23岁(包括20岁和23岁)之间的学生的姓名、出生日期和主修专业
SELECT sname, sbirthdate, smajor 
FROM en.student
WHERE EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM sbirthdate) BETWEEN 20 AND 23;

-- 例3.26 查询年龄不在20~23岁范围内的学生的姓名、出生日期和主修专业
SELECT sname, sbirthdate, smajor
FROM en.student
WHERE EXTRACT(YEAR FROM current_date) - EXTRACT(YEAR FROM sbirthdate)
NOT BETWEEN 20 AND 23;

-- 例3.27 查询计算机科学与技术专业和信息安全专业的学生的姓名及性别
SELECT sname, ssex
FROM en.student
WHERE smajor IN ('计算机科学与技术', '信息安全');
-- 与IN相对的谓词是NOT IN，用于查找属性值不属于指定集合的元组

-- 例3.28 查询非计算机科学与技术专业和信息安全专业的学生的姓名和性别
SELECT sname, ssex FROM en.student
WHERE smajor NOT IN ('计算机科学与技术', '信息安全');

-- 例3.29 查询学号为20180003的学生的详细情况
SELECT *
FROM en.student
WHERE sno = '20180003';

-- 例3.30 查询所有姓刘的学生的姓名、学号和性别
SELECT sname, sno, ssex
FROM en.student
WHERE sname LIKE '刘%';

-- 例3.31 查询2018级学生的学号和姓名
SELECT sno, sname
FROM en.student
WHERE sno LIKE '2018%';
-- 学号的数据类型是字符，用字符匹配

-- 例3.32 查询课程号为81开头，最后一位是6的课程名称和课程号
SELECT cname, cno
FROM en.course
WHERE cno LIKE '81__6';
-- 注意课程关系中课程号为固定长度，占5个字符大小

-- 例3.33 查询所有不姓刘的学生的姓名、学号和性别
SELECT sname, sno, ssex FROM en.student
WHERE sname NOT LIKE '刘%';

-- 如果用户要查询的字符串本身就含有通配符%或_，这时就要使用ESCAPE短语对通配符进行转义了
-- 例3.34 查询DB_Design课程的课程号和学分
-- 假设已插入了一条数据库设计课程元组，课程名称为DB_Design
SELECT cno, ccredit
FROM en.course
WHERE cname LIKE 'DB\_Design' ESCAPE '\';
-- "ESCAPE \" 表示"\"换码字符。这样匹配串中紧跟在"\"后面的字符"_"不再具有通配符的含义，转义为普通的"_"字符

-- 例3.35 查询以"DB_"开头，且倒数第三个字符为i的课程的详细情况
SELECT *
FROM en.course
WHERE cname LIKE 'DB\_%i__' ESCAPE '\';
-- 这里的匹配串为"DB\_%i__" ESCAPE "\"。第一个"_"前有换码字符"\"，所以它被转义为普通的"_"字符。而"i"后的两个"_"的前面均没有换码字符"\""，所以它们仍作为通配符。

-- 3.3.1.5 涉及空值的查询
-- 例3.36 某些学生选修课程后没有参加考试，所以有选课记录但没有考试成绩。查询缺少成绩的学生的学号和相应的课程号
SELECT sno, cno 
FROM en.sc
WHERE grade IS NULL;
-- 分数grade是空值。注意这里的"IS"不能用等号(=)代替

-- 例3.37 查询所有有成绩的学生的学号和选修的课程号
SELECT sno, cno 
FROM en.sc
WHERE grade IS NOT NULL;

-- 3.3.1.6 多重条件查询
-- 逻辑运算符AND和OR可用来连接多个查询条件。AND的优先级高于OR，但用户可以用括号改变优先级
-- 例3.38 查询主修计算机科学与技术专业，在2000年(包括2000年)以后出生的学生的学号、姓名和性别
SELECT sno, sname, ssex 
FROM en.student
WHERE smajor = '计算机科学与技术' 
  AND EXTRACT(YEAR FROM sbirthdate) >= 2000;

-- 3.3.1.3 ORDER BY子句
-- 例3.39 查询选修了81003号课程的学生的学号及其成绩，查询结果按分数的降序排列
SELECT sno, grade 
FROM en.sc
WHERE cno = '81003'
ORDER BY grade DESC;

-- 例3.40 查询全体学生选修课程情况，查询结果先按照课程号升序排列，同一课程中按成绩降序排列
SELECT *
FROM en.sc
ORDER BY cno, grade DESC;
-- 排序字段的说明默认为升序ASC，可以省略，而DESC需要明确写出来

-- 3.3.1.4 聚集函数
-- 聚集函数用于对一组值进行计算并返回单个值

-- COUNT(*)                   统计元组个数
-- COUNT([DISTINCT|ALL]<列名>) 统计一列中值的个数
-- SUM([DISTINCT|ALL]<列名>)   计算一列值的总和(此列必须是数值型)
-- AVG([DISTINCT|ALL]<列名>)   计算一列值的平均值(此列必须是数值型)
-- MAX([DISTINCT|ALL]<列名>)   求一列值中的最大值
-- MIN([DISTINCT|ALL]<列名>)   求一列值中的最小值
-- 说明：
-- DISTINCT: 去除重复值后计算
-- ALL: 对所有值计算(默认值，可省略)
-- 除COUNT(*)外，其他聚集函数都会忽略NULL值

-- 例3.41 查询学生总人数
SELECT COUNT(*)
FROM en.student;

-- 例3.42 查询选修了课程的学生人数
SELECT COUNT(DISTINCT sno) 
FROM en.sc;

-- 例3.43 计算选修81001号课程的学生平均成绩
SELECT AVG(grade) 
FROM en.sc
WHERE cno = '81001';

-- 例3.44 查询选修81001号课程的学生最高分数
SELECT MAX(grade)
FROM en.sc
WHERE cno = '81001';

-- 例3.45 查询学号为20180003的学生选修课程的总学分数
SELECT SUM(ccredit)
FROM en.sc sc, en.course c
WHERE sc.sno = '20180003' 
  AND sc.cno = c.cno;

-- 3.3.1.5 GROUP BY子句
-- 例3.46 求各个课程号及选修该课程的人数
SELECT cno, COUNT(sno)
FROM en.sc 
GROUP BY cno;

-- 例3.47 查询2019年第2学期选修课程数超过10门的学生学号
SELECT sno
FROM en.sc
WHERE semester = '20192' 
GROUP BY sno
HAVING COUNT(*) > 10;

-- 例3.48 查询平均成绩大于或等于90分的学生学号和平均成绩
SELECT sno, AVG(grade) 
FROM en.sc
GROUP BY sno
HAVING AVG(grade) >= 90;

-- 例3.49 查询选修数据库系统概论课程且成绩排名在前10名的学生的学号
SELECT sc.sno
FROM en.sc sc, en.course c
WHERE c.cname = '数据库系统概论' 
  AND sc.cno = c.cno
ORDER BY sc.grade DESC
LIMIT 10;
-- 取前10行数据为查询结果

-- 例3.50 查询平均成绩排名在第3~7名的学生的学号和平均成绩
SELECT sno, AVG(grade)
FROM en.sc
GROUP BY sno
ORDER BY AVG(grade) DESC
LIMIT 5 OFFSET 2;
-- 取5行数据，忽略前2行，之后为查询结果数据

-- ===========================================
-- 3.3.2 连接查询
-- ===========================================

-- 例3.51 查询每个学生及其选修课程的情况
-- 学生情况存放在Student表中，学生选课情况存放在SC表中，所以本查询实际上涉及Student与SC两个表。这两个表之间的联系是通过公共属性sno实现的。
SELECT s.*, sc.*
FROM en.student s, en.sc sc
WHERE s.sno = sc.sno;
-- 将Student与SC中同一学生的元组连接起来

-- 例3.52 查询每个学生的学号、姓名、性别、出生日期、主修专业及该学生选修课程的课程号与成绩
SELECT s.sno, s.sname, s.ssex, s.sbirthdate, s.smajor, sc.cno, sc.grade 
FROM en.student s, en.sc sc
WHERE s.sno = sc.sno;

-- 例3.53 查询选修81002号课程且成绩在90分以上的所有学生的学号和姓名
SELECT s.sno, s.sname
FROM en.student s, en.sc sc
WHERE s.sno = sc.sno 
  AND sc.cno = '81002' 
  AND sc.grade > 90;

-- 例3.54 查询每一门课的间接先修课(即先修课的先修课)
SELECT first.cno, second.cpno
FROM en.course first, en.course second
WHERE first.cpno = second.cno AND second.cpno IS NOT NULL;

-- 3.3.2.3 外连接查询
-- 例3.55 查询所有学生的学号、姓名、性别、出生日期、主修专业、课程号和成绩（包括没有选课的学生）
SELECT s.sno, s.sname, s.ssex, s.sbirthdate, s.smajor, sc.cno, sc.grade
FROM en.student s 
LEFT OUTER JOIN en.sc sc ON s.sno = sc.sno;
-- 左外连接列出FROM子句中左边关系(如本例Student)所有的元组，右外连接列出FROM子句中右边关系中(如本例SC)所有的元组

-- 3.3.2.4 多表连接查询
-- 例3.56 查询每个学生的学号、姓名、选修的课程名及成绩
-- 本例查询涉及3个表，存放学生学号和姓名的Student表、存放学生选课成绩的SC表和存放课程名的Course表。完成该查询的SQL语句如下:
SELECT s.sno, s.sname, c.cname, sc.grade
FROM en.student s, en.sc sc, en.course c
WHERE s.sno = sc.sno 
  AND sc.cno = c.cno;

-- ===========================================
-- 3.3.3 嵌套查询
-- ===========================================

-- 在SQL中，一个SELECT-FROM-WHERE语句称为一个查询块。将一个查询块嵌套在另一个查询块的WHERE子句或HAVING短语的条件中的查询称为嵌套查询(nested query)
-- 例如，查询选修81003号课程的所有学生姓名，其SQL语句如下:
SELECT sname 
FROM en.student 
WHERE sno IN (
    SELECT sno 
    FROM en.sc
    WHERE cno = '81003'
);
-- 外层查询或父查询内层查询或子查询

-- 例3.57 查询与"刘晨"在同一个主修专业的学生学号、姓名和主修专业
-- 先分步来完成此查询，然后再构造嵌套查询
-- 1. 确定"刘晨"的主修专业名
SELECT smajor 
FROM en.student
WHERE sname = '刘晨';
-- 结果为计算机科学与技术

-- 2. 查找所有主修计算机科学与技术专业的学生
SELECT sno, sname, smajor 
FROM en.student
WHERE smajor = '计算机科学与技术';

-- 3. 构造嵌套查询
SELECT sno, sname, smajor 
FROM en.student
WHERE smajor = (
    SELECT smajor 
    FROM en.student 
    WHERE sname = '刘晨'
);

-- 例3.58 查询选修了课程名为"信息系统概论"的学生的学号和姓名
-- 本查询涉及学号、姓名和课程名三个属性。学号和姓名存放在Student表中，课程名存放在Course表中，但Student与Course两个表之间没有直接联系，必须通过SC表建立它们之间的联系。所以本查询实际上涉及三个关系。
SELECT sno, sname 
FROM en.student
WHERE sno IN (
    SELECT sno
    FROM en.sc 
    WHERE cno IN (
        SELECT cno
        FROM en.course
        WHERE cname = '信息系统概论'
    )
);

-- 例3.59 找出每个学生超过他自己选修课程平均成绩的课程号
SELECT sno, cno
FROM en.sc x
WHERE grade >= (SELECT AVG(grade) -- 某学生的平均成绩
FROM en.sc y
WHERE y.sno = x.sno);

-- 例3.60 查询非计算机科学与技术专业中比计算机科学与技术专业任意一个年龄小(出生日期晚)的学生的姓名、出生日期和主修专业
SELECT sname, sbirthdate, smajor
FROM en.student
WHERE sbirthdate > ANY (SELECT sbirthdate
FROM en.student
WHERE smajor = '计算机科学与技术')
AND smajor <> '计算机科学与技术';
-- 注意这是父查询块中的条件

-- 例3.61 查询非计算机科学与技术专业中比计算机科学与技术专业所有学生年龄都小(出生日期晚)的学生的姓名及出生日期
SELECT sname, sbirthdate FROM en.student
WHERE sbirthdate > ALL (SELECT sbirthdate
FROM en.student
WHERE smajor = '计算机科学与技术') AND smajor <> '计算机科学与技术';


-- 例3.62 查询所有选修了81001号课程的学生姓名
-- 本查询涉及Student和SC表。可以在Student中依次取每个元组的sno值，用此值去检查SC表。若SC中存在这样的元组，其sno值等于此Student.sno值，并且其cno='81001'，则取此Student.sname送入结果表。将此想法写成SQL语句如下:
SELECT sname FROM en.student WHERE EXISTS
(SELECT *
FROM en.sc
WHERE sno = en.student.sno AND cno = '81001');
-- 使用存在量词EXISTS后，若内层查询结果非空，则外层的WHERE子句返回真值，否则返回假值

-- 例3.63 查询没有选修81001号课程的学生姓名
SELECT sname FROM en.student
WHERE NOT EXISTS
(SELECT * FROM en.sc
WHERE sno = en.student.sno AND cno = '81001');

-- 例3.64 查询选修了全部课程的学生姓名
-- SQL中没有全称量词(for all)，但是可以把带有全称量词的谓词转换为等价的带有存在量词的谓词:
-- (∀x)P = ¬(∃x(¬P)) 由于没有全称量词，可将题目的意思转换成等价的用存在量词的形式:查询这样的学生，没有一门课程是他不选修的。其SQL语句如下:
SELECT sname
FROM en.student WHERE NOT EXISTS
(SELECT *
FROM en.course
WHERE NOT EXISTS
(SELECT * FROM en.sc
WHERE sno = en.student.sno AND cno = en.course.cno));

-- 例3.65 查询至少选修了学生20180002选修的全部课程的学生学号
SELECT sno
FROM en.student
WHERE NOT EXISTS
(SELECT * -- 这是一个相关子查询
FROM en.sc scx  -- 父查询和子查询均引用了SC表
WHERE scx.sno = '20180002' AND
NOT EXISTS
(SELECT *
FROM en.sc scy
-- 用别名scx、scy将父查询与子查询中的SC表区分开
WHERE scy.sno = en.student.sno AND scy.cno = scx.cno));


-- 3.3.2.3 外连接
-- 例3.49 改写例3.45，查询每个学生及其选修课程的情况（包括没有选课的学生）
SELECT s.sno, s.sname, sc.cno, sc.grade 
FROM en.student s
LEFT OUTER JOIN en.sc sc ON s.sno = sc.sno;

-- 例3.50 查询所有学生的学号、姓名、选课名称及成绩
SELECT s.sno, s.sname, c.cname, sc.grade 
FROM en.student s
LEFT OUTER JOIN en.sc sc ON s.sno = sc.sno
LEFT OUTER JOIN en.course c ON sc.cno = c.cno;

-- 3.3.2.4 多表连接
-- 例3.51 查询每个学生的学号、姓名、选修的课程名及成绩
SELECT s.sno, s.sname, c.cname, sc.grade 
FROM en.student s, en.sc sc, en.course c 
WHERE s.sno = sc.sno AND sc.cno = c.cno;

-- 使用JOIN语法
SELECT s.sno, s.sname, c.cname, sc.grade 
FROM en.student s
JOIN en.sc sc ON s.sno = sc.sno
JOIN en.course c ON sc.cno = c.cno;

-- ===========================================
-- 3.3.3 嵌套查询
-- ===========================================

-- 3.3.3.1 带有IN谓词的子查询
-- 例3.52 查询与"刘晨"在同一个系学习的学生
SELECT sno, sname, smajor 
FROM en.student 
WHERE smajor IN (
    SELECT smajor FROM en.student WHERE sname = '刘晨'
) AND sname != '刘晨';

-- 例3.53 查询选修了课程名为"信息系统"的学生学号和姓名
SELECT sno, sname 
FROM en.student 
WHERE sno IN (
    SELECT sno FROM en.sc WHERE cno IN (
        SELECT cno FROM en.course WHERE cname = '信息系统概论'
    )
);

-- 3.3.3.2 带有比较运算符的子查询
-- 例3.54 找出每个学生超过他选修课程平均成绩的课程号
SELECT sno, cno 
FROM en.sc x 
WHERE grade >= (
    SELECT AVG(grade) FROM en.sc y WHERE y.sno = x.sno
);

-- 例3.55 查询其他系中比计算机科学系某一学生年龄小的学生姓名和年龄
SELECT sname, sage 
FROM en.student 
WHERE sage < ANY (
    SELECT sage FROM en.student WHERE smajor = '计算机科学与技术'
) AND smajor != '计算机科学与技术';

-- 例3.56 查询其他系中比计算机科学系所有学生年龄都小的学生姓名和年龄
SELECT sname, sage 
FROM en.student 
WHERE sage < ALL (
    SELECT sage FROM en.student WHERE smajor = '计算机科学与技术'
) AND smajor != '计算机科学与技术';

-- 3.3.3.3 带有EXISTS谓词的子查询
-- 例3.57 查询所有选修了1号课程的学生姓名
SELECT sname 
FROM en.student 
WHERE EXISTS (
    SELECT * FROM en.sc WHERE sno = en.student.sno AND cno = '81001'
);

-- 例3.58 查询没有选修1号课程的学生姓名
SELECT sname 
FROM en.student 
WHERE NOT EXISTS (
    SELECT * FROM en.sc WHERE sno = en.student.sno AND cno = '81001'
);

-- 例3.59 查询选修了全部课程的学生姓名
SELECT sname 
FROM en.student 
WHERE NOT EXISTS (
    SELECT * FROM en.course 
    WHERE NOT EXISTS (
        SELECT * FROM en.sc 
        WHERE sno = en.student.sno AND cno = en.course.cno
    )
);

-- ===========================================
-- 3.3.4 集合查询
-- ===========================================

-- 例3.60 查询计算机科学系的学生及年龄不大于19岁的学生
SELECT * FROM en.student WHERE smajor = '计算机科学与技术'
UNION
SELECT * FROM en.student WHERE sage <= 19;

-- 例3.61 查询选修课程1或者选修课程2的学生
SELECT sno FROM en.sc WHERE cno = '81001'
UNION
SELECT sno FROM en.sc WHERE cno = '81002';

-- 例3.62 查询计算机科学系的学生与年龄不大于19岁的学生的交集
SELECT * FROM en.student WHERE smajor = '计算机科学与技术'
INTERSECT
SELECT * FROM en.student WHERE sage <= 19;

-- 例3.63 查询选修课程1的学生集合与选修课程2的学生集合的交集
SELECT sno FROM en.sc WHERE cno = '81001'
INTERSECT
SELECT sno FROM en.sc WHERE cno = '81002';

-- 例3.64 查询计算机科学系的学生与年龄不大于19岁的学生的差集
SELECT * FROM en.student WHERE smajor = '计算机科学与技术'
EXCEPT
SELECT * FROM en.student WHERE sage <= 19;

-- ===========================================
-- 3.3.5 基于派生表的查询
-- ===========================================

-- 例3.65 找出每个学生超过他自己选修课程平均成绩的课程号
SELECT sno, cno 
FROM en.sc, (
    SELECT sno, AVG(grade) AS Avg_grade 
    FROM en.sc 
    GROUP BY sno
) AS Avg_SC 
WHERE en.sc.sno = Avg_SC.sno AND en.sc.grade > Avg_SC.Avg_grade;

-- 使用CTE（Common Table Expression）语法（PostgreSQL推荐）
WITH avg_sc AS (
    SELECT sno, AVG(grade) AS avg_grade 
    FROM en.sc 
    GROUP BY sno
)
SELECT sc.sno, sc.cno 
FROM en.sc sc
JOIN avg_sc avg_sc ON sc.sno = avg_sc.sno 
WHERE sc.grade > avg_sc.avg_grade;



-- 例3.70 查询各系学生人数、平均年龄、最高年龄、最低年龄
SELECT smajor,
       COUNT(*) AS student_count,
       ROUND(AVG(sage), 2) AS avg_age,
       MAX(sage) AS max_age,
       MIN(sage) AS min_age
FROM en.student
GROUP BY smajor
ORDER BY student_count DESC;

-- 例3.71 查询每门课程的选课人数、平均成绩、最高成绩、最低成绩
SELECT c.cno, c.cname,
       COUNT(sc.sno) AS student_count,
       ROUND(AVG(sc.grade), 2) AS avg_grade,
       MAX(sc.grade) AS max_grade,
       MIN(sc.grade) AS min_grade
FROM en.course c
LEFT JOIN en.sc sc ON c.cno = sc.cno
GROUP BY c.cno, c.cname
ORDER BY student_count DESC;

-- 例3.72 查询成绩优秀的学生（平均成绩≥85分）及其详细信息
SELECT s.sno, s.sname, s.smajor,
       COUNT(sc.cno) AS course_count,
       ROUND(AVG(sc.grade), 2) AS avg_grade
FROM en.student s
JOIN en.sc sc ON s.sno = sc.sno
WHERE sc.grade IS NOT NULL
GROUP BY s.sno, s.sname, s.smajor
HAVING AVG(sc.grade) >= 85
ORDER BY avg_grade DESC;

-- 例3.73 查询每个专业成绩最好的学生
WITH student_grades AS (
    SELECT s.sno, s.sname, s.smajor, AVG(sc.grade) AS avg_grade
    FROM en.student s
    JOIN en.sc sc ON s.sno = sc.sno
    WHERE sc.grade IS NOT NULL
    GROUP BY s.sno, s.sname, s.smajor
),
ranked_students AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY smajor ORDER BY avg_grade DESC) AS rn
    FROM student_grades
)
SELECT sno, sname, smajor, avg_grade
FROM ranked_students
WHERE rn = 1;

-- ===========================================
-- 3.3.9 查询性能优化示例
-- ===========================================

-- 例3.74 使用EXPLAIN分析查询执行计划
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT s.sname, c.cname, sc.grade
FROM en.student s
JOIN en.sc sc ON s.sno = sc.sno
JOIN en.course c ON sc.cno = c.cno
WHERE s.smajor = '计算机科学与技术' AND sc.grade > 80;

-- 例3.75 创建索引优化查询性能
-- 为常用查询条件创建索引
CREATE INDEX IF NOT EXISTS idx_student_major ON en.student(smajor);
CREATE INDEX IF NOT EXISTS idx_sc_grade ON en.sc(grade);
CREATE INDEX IF NOT EXISTS idx_sc_sno_cno ON en.sc(sno, cno);

-- ===========================================
-- 3.3.10 数据验证查询
-- ===========================================

-- 例3.76 验证数据完整性
-- 检查外键约束
SELECT 'Foreign Key Violations' AS check_type, COUNT(*) AS violation_count
FROM en.sc sc
WHERE NOT EXISTS (SELECT 1 FROM en.student s WHERE s.sno = sc.sno)
   OR NOT EXISTS (SELECT 1 FROM en.course c WHERE c.cno = sc.cno);

-- 检查成绩范围
SELECT 'grade Range Violations' AS check_type, COUNT(*) AS violation_count
FROM en.sc
WHERE grade < 0 OR grade > 100;

-- 检查学期格式
SELECT 'Semester Format Violations' AS check_type, COUNT(*) AS violation_count
FROM en.sc
WHERE semester !~ '^[0-9]{4}[12]$';

-- ===========================================
-- 实验总结
-- ===========================================

/*
第3.3章 数据查询 实验要点：

1. 单表查询
   - 选择列：SELECT子句
   - 选择行：WHERE子句
   - 排序：ORDER BY子句
   - 分组：GROUP BY子句
   - 聚集函数：COUNT, SUM, AVG, MAX, MIN

2. 连接查询
   - 等值连接：WHERE条件中的等号连接
   - 自然连接：NATURAL JOIN
   - 外连接：LEFT/RIGHT/FULL OUTER JOIN
   - 自连接：表与自身的连接

3. 嵌套查询
   - 带有IN谓词的子查询
   - 带有比较运算符的子查询
   - 带有EXISTS谓词的子查询
   - 相关子查询与非相关子查询

4. 集合查询
   - 并集：UNION
   - 交集：INTERSECT
   - 差集：EXCEPT

5. 高级查询
   - 派生表查询
   - 窗口函数：ROW_NUMBER, RANK, DENSE_RANK
   - 递归查询：WITH RECURSIVE
   - CTE（公共表表达式）

6. PostgreSQL 17 特性
   - 增强的窗口函数支持
   - 改进的查询优化器
   - 更好的JSON查询支持
   - 递归查询优化

注意事项：
- 使用JOIN语法比WHERE连接更清晰
- 合理使用索引提高查询性能
- 注意NULL值的处理
- 使用EXPLAIN分析查询计划
- 窗口函数可以简化复杂的排名和统计查询
- 递归查询适用于层次结构数据
*/
