**备份 Memos SQLite 数据库文件**

备份脚本没有Memos版本区别，支持所有版本。

**功能：**
1. 如果备份目录不存在，自动创建备份目录
2. 自动将未写入SQLite的操作写入DB文件
3. 备份文件自动添加时间后缀
4. 自动清除超过30天的备份文件（可以自己修改脚本更改保留天数）

**手动备份：**
1. 复制脚本文件（memosbackup_sqlite.sh）到SQLite数据库文件目录下
2. 运行下面命令备份到当前目录下的memosbak目录
```
sudo bash memosbackup_sqlite.sh
```

**自动备份：**
在cron job中添加任务（建议在root下运行）
1. 运行
```
crontab -e
```
2. 添加下面语句到文件的最后
```
# 请自行修改脚本文件的路径
# 此命令是每天凌晨12点时备份
0 0 * * * bash /home/usr/.memos/memosbackup_sqlite.sh 
```
3. 按 CTRL+X 退出，按 y 选择保存，按回车确认
4. 然后不用管了，只要机器开着，每天 cron job 会自动帮你备份

**cron job 自动运行时间**
这个可以自己上网查查，下面给几个常用的
```
# 每小时备份一次
0 * * * * bash /home/usr/.memos/memosbackup_sqlite.sh
```
```
# 每6小时备份一次
0 */6 * * * bash /home/usr/.memos/memosbackup_sqlite.sh
```
```
# 每天中午12点和凌晨12点备份
0 0,12 * * * bash /home/usr/.memos/memosbackup_sqlite.sh
```
