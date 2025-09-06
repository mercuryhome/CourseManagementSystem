#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>
#include <locale.h>

// 函数声明
static int get_display_width(const char *str);
static void print_padded(const char *str, int target_width);

// 计算字符串的显示宽度（考虑中文字符）
static int get_display_width(const char *str) {
    int width = 0;
    int len;
    int i;
    
    if (!str) return 4; // "NULL"
    
    len = strlen(str);
    
    for (i = 0; i < len; ) {
        unsigned char c = (unsigned char)str[i];
        if (c < 0x80) {
            // ASCII字符，宽度为1
            width += 1;
            i++;
        } else if ((c & 0xE0) == 0xC0) {
            // UTF-8 2字节字符（如中文），宽度为2
            width += 2;
            i += 2;
        } else if ((c & 0xF0) == 0xE0) {
            // UTF-8 3字节字符，宽度为2
            width += 2;
            i += 3;
        } else if ((c & 0xF8) == 0xF0) {
            // UTF-8 4字节字符，宽度为2
            width += 2;
            i += 4;
        } else {
            // 其他情况，按1个字符处理
            width += 1;
            i++;
        }
    }
    return width;
}

// 打印指定宽度的字符串，不足部分用空格填充
static void print_padded(const char *str, int target_width) {
    int current_width;
    int padding;
    int i;
    
    if (!str) str = "NULL";
    
    current_width = get_display_width(str);
    padding = target_width - current_width;
    
    printf("%s", str);
    for (i = 0; i < padding; i++) {
        printf(" ");
    }
}

int main() {
    PGconn *conn;
    PGresult *res;
    int i, j, k;
    const char *conninfo;
    const char *query;
    int col_widths[] = {12, 10, 6, 12, 20};
    
    // 设置本地化环境以支持中文字符
    setlocale(LC_ALL, "zh_CN.UTF-8");
    
    // 数据库连接参数
    conninfo = "host=localhost port=5432 dbname=db_cms_dev user=postgres password=your_password";
    
    printf("正在连接PostgreSQL数据库...\n");
    printf("连接信息: %s\n", conninfo);
    
    // 建立数据库连接
    conn = PQconnectdb(conninfo);
    
    // 检查连接状态
    if (PQstatus(conn) != CONNECTION_OK) {
        fprintf(stderr, "连接数据库失败: %s", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }
    
    printf("数据库连接成功！\n\n");
    
    // 执行查询语句 - 查询en模式下的student表前5条记录
    query = "SELECT Sno, Sname, Ssex, Sbirthdate, Smajor FROM en.Student LIMIT 5";
    
    printf("执行查询: %s\n\n", query);
    
    res = PQexec(conn, query);
    
    // 检查查询执行状态
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        fprintf(stderr, "查询执行失败: %s", PQerrorMessage(conn));
        PQclear(res);
        PQfinish(conn);
        exit(1);
    }
    
    // 打印表头
    printf("查询结果 (共 %d 条记录):\n", PQntuples(res));
    printf("=============================================================\n");
    
    // 列宽设置（考虑中文字符显示宽度）
    
    // 打印表头 - 使用for循环优化
    for (i = 0; i < 5; i++) {
        print_padded(PQfname(res, i), col_widths[i]);
        if (i < 4) printf(" ");
    }
    printf("\n");
    
    // 打印分隔线
    for (j = 0; j < 5; j++) {
        for (k = 0; k < col_widths[j]; k++) {
            printf("-");
        }
        if (j < 4) printf(" ");
    }
    printf("\n");
    
    // 打印查询结果 - 使用for循环优化
    for (i = 0; i < PQntuples(res); i++) {
        for (j = 0; j < 5; j++) {
            char *value = PQgetvalue(res, i, j);
            print_padded(value, col_widths[j]);
            if (j < 4) printf(" ");
        }
        printf("\n");
    }
    
    printf("=============================================================\n");
    printf("查询完成！\n");
    
    // 清理资源
    PQclear(res);
    PQfinish(conn);
    
    return 0;
}
