#include <stdio.h>
#include <string.h>
#include <wchar.h>
#include <locale.h>

// 计算字符串的显示宽度（考虑中文字符）
int get_display_width(const char *str) {
    if (!str) return 4; // "NULL"
    
    int width = 0;
    int len = strlen(str);
    
    for (int i = 0; i < len; ) {
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
void print_padded(const char *str, int target_width) {
    if (!str) str = "NULL";
    
    int current_width = get_display_width(str);
    int padding = target_width - current_width;
    
    printf("%s", str);
    for (int i = 0; i < padding; i++) {
        printf(" ");
    }
}

int main() {
    setlocale(LC_ALL, "zh_CN.UTF-8");
    
    printf("测试中文字符对齐:\n");
    printf("=============================================================\n");
    
    // 测试数据
    const char *data[][5] = {
        {"20180001", "李勇", "男", "2000-03-08", "信息安全"},
        {"20180002", "刘晨", "女", "1999-09-01", "计算机科学与技术"},
        {"20180003", "王敏", "女", "2001-08-01", "信息管理与信息系统"},
        {"20180004", "张立", "男", "2000-01-08", "数据科学与大数据技术"},
        {"20180005", "陈新奇", "男", "2001-11-01", "信息安全"}
    };
    
    // 列宽设置
    int col_widths[] = {12, 18, 8, 14, 28};
    
    // 打印表头
    print_padded("Sno", col_widths[0]);
    print_padded("Sname", col_widths[1]);
    print_padded("Ssex", col_widths[2]);
    print_padded("Sbirthdate", col_widths[3]);
    print_padded("Smajor", col_widths[4]);
    printf("\n");
    
    // 打印分隔线
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < col_widths[i]; j++) {
            printf("-");
        }
        if (i < 4) printf(" ");
    }
    printf("\n");
    
    // 打印数据
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            print_padded(data[i][j], col_widths[j]);
            if (j < 4) printf(" ");
        }
        printf("\n");
    }
    
    printf("=============================================================\n");
    
    return 0;
}
