# 2. The SQL Language

## 2.1. Introduction

This chapter provides an overview of how to use SQL to perform simple operations. This tutorial is only intended to give you an introduction and is in no way a complete tutorial on SQL. Numerous books have been written on SQL, including [melt93] and [date97]. You should be aware that some PostgreSQL language features are extensions to the standard.

In the examples that follow, we assume that you have created a database named mydb, as described in the previous chapter, and have been able to start psql.

Examples in this manual can also be found in the PostgreSQL source distribution in the directory `src/tutorial/`. (Binary distributions of PostgreSQL might not provide those files.) To use those files, first change to that directory and run make:

```bash
# 获取最新的代码库文件
$ cd ~/workspace/database/CourseManagementSystem/
$ git pull
$ cd /workspace/database/CourseManagementSystem/src/tutorial
$ ls -l    # 可以看到以下文件
basics.sql	weather.txt

# 创建数据库
$ createdb mydb
$ psql -d mydb < basics.sql 

# 可以看到 basics.sql 语句的输出结果. 
# 打开basics.sql 文件查看sql语句，了解这些语句做了什么？
```

## 2.2. Concepts

PostgreSQL is a relational database management system (RDBMS). That means it is a system for managing data stored in relations. Relation is essentially a mathematical term for table. The notion of storing data in tables is so commonplace today that it might seem inherently obvious, but there are a number of other ways of organizing databases. Files and directories on Unix-like operating systems form an example of a hierarchical database. A more modern development is the object-oriented database.

Each table is a named collection of rows. Each row of a given table has the same set of named columns, and each column is of a specific data type. Whereas columns have a fixed order in each row, it is important to remember that SQL does not guarantee the order of the rows within the table in any way (although they can be explicitly sorted for display).

Tables are grouped into databases, and a collection of databases managed by a single PostgreSQL server instance constitutes a database cluster.

## 2.3. Creating a New Table

You can create a new table by specifying the table name, along with all column names and their types:

```bash
$ psql -d mydb

  mydb=# CREATE TABLE weather (
    city varchar(80),
    temp_lo int, -- low temperature
    temp_hi int, -- high temperature
    prcp real, -- precipitation
    date date
  );
```

You can enter this into psql with the line breaks. psql will recognize that the command is not terminated until the semicolon.

White space (i.e., spaces, tabs, and newlines) can be used freely in SQL commands. That means you can type the command aligned differently than above, or even all on one line. Two dashes ("--") introduce comments. Whatever follows them is ignored up to the end of the line. SQL is case-insensitive about key words and identifiers, except when identifiers are double-quoted to preserve the case (not done above).

`varchar(80)` specifies a data type that can store arbitrary character strings up to 80 characters in length. `int` is the normal integer type. `real` is a type for storing single precision floating-point numbers. `date` should be self-explanatory. (Yes, the column of type date is also named date. This might be convenient or confusing — you choose.)

PostgreSQL supports the standard SQL types `int`, `smallint`, `real`, `double precision`, `char(N)`, `varchar(N)`, `date`, `time`, `timestamp`, and `interval`, as well as other types of general utility and a rich set of geometric types. PostgreSQL can be customized with an arbitrary number of user-defined data types. Consequently, type names are not key words in the syntax, except where required to support special cases in the SQL standard.

The second example will store cities and their associated geographical location:

```bash
mydb=# CREATE TABLE cities (
  name varchar(80),
  location point
);
```

The `point` type is an example of a PostgreSQL-specific data type.

Finally, it should be mentioned that if you don't need a table any longer or want to recreate it differently 

you can remove it using the following command:

```bash
mydb=# DROP TABLE tablename;
```

## 2.4. Populating a Table With Rows

The INSERT statement is used to populate a table with rows:

```bash
mydb=# INSERT INTO weather VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27');
```

Note that all data types use rather obvious input formats. Constants that are not simple numeric values usually must be surrounded by single quotes ('), as in the example. The date type is actually quite flexible in what it accepts, but for this tutorial we will stick to the unambiguous format shown here.

The point type requires a coordinate pair as input, as shown here:

The syntax used so far requires you to remember the order of the columns. An alternative syntax allows you to list the columns explicitly:

```bash
mydb=# INSERT INTO cities VALUES ('San Francisco', '(-194.0, 53.0)');
```

You can list the columns in a different order if you wish or even omit some columns, e.g., if the precipitation is unknown:

'''bash
mydb=# INSERT INTO weather (date, city, temp_hi, temp_lo)
VALUES ('1994-11-29', 'Hayward', 54, 37);
'''

Many developers consider explicitly listing the columns better style than relying on the order implicitly.

Please enter all the commands shown above so you have some data to work with in the following sections.

You could also have used COPY to load large amounts of data from flat-text files. This is usually faster because the COPY command is optimized for this application while allowing less flexibility than INSERT. An example would be:

```bash
$ cd ~workspace/database/CourseManagementSystem/src/tutorial

$ cat weather.txt
San Francisco 46 50 0.25 1994-11-27
San Francisco 43 57 0.0 1994-11-29
Hayward 37 54 \N 1994-11-29

$ psql -d mydb

mydb=# \COPY weather FROM 'weather.txt';
```

where the file name for the source file must be available on the machine running the backend process, not the client, since the backend process reads the file directly. The data inserted above into the weather table could also be inserted from a file containing (values are separated by a tab character):

You can read more about the COPY command in COPY.

> \COPY 和 COPY 的区别

```sql
\COPY 表名 FROM 文件;     # 文件在PostgreSQL Client(客户端） 
COPY 表名 FROM 文件;      # 文件在PostgreSQL serve(服务器端） 
```

## 2.5. Querying a Table

To retrieve data from a table, the table is queried. An SQL SELECT statement is used to do this. The statement is divided into a select list (the part that lists the columns to be returned), a table list (the part that lists the tables from which to retrieve the data), and an optional qualification (the part that specifies any restrictions). For example, to retrieve all the rows of table weather, type:

```sql
mydb=# SELECT * FROM weather;

     city      | temp_lo | temp_hi | prcp |    date    
---------------+---------+---------+------+------------
 San Francisco |      46 |      50 | 0.25 | 1994-11-27
 San Francisco |      43 |      57 |    0 | 1994-11-29
 Hayward       |      37 |      54 |      | 1994-11-29
(3 行记录)
```