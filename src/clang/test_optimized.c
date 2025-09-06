#include <stdio.h>
#include <string.h>
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
    int i, j, k;
    int col_widths[] = {12, 10, 4, 12, 20};
    
    // 设置本地化环境以支持中文字符
    setlocale(LC_ALL, "zh_CN.UTF-8");
    
    printf("优化后的输出格式 (使用for循环):\n");
    printf("=============================================================\n");
    
    // 模拟表头数据
    const char *headers[] = {"Sno", "Sname", "Ssex", "Sbirthdate", "Smajor"};
    
    // 模拟数据
    const char *data[][5] = {
        {"20180001", "李勇", "男", "2000-03-08", "信息安全"},
        {"20180002", "刘晨", "女", "1999-09-01", "计算机科学与技术"},
        {"20180003", "王敏", "女", "2001-08-01", "信息管理与信息系统"},
        {"20180004", "张立", "男", "2000-01-08", "数据科学与大数据技术"},
        {"20180005", "陈新奇", "男", "2001-11-01", "信息安全"}
    };
    
    // 打印表头 - 使用for循环优化
    for (i = 0; i < 5; i++) {
        print_padded(headers[i], col_widths[i]);
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
    for (i = 0; i < 5; i++) {
        for (j = 0; j < 5; j++) {
            print_padded(data[i][j], col_widths[j]);
            if (j < 4) printf(" ");
        }
        printf("\n");
    }
    
    printf("=============================================================\n");
    printf("代码优化完成！\n");
    
    return 0;
}
