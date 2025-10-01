**Memos Database Migration** (supported version)

**From SQLite to MySQL** (version 0.21.0, 0.22.x, 0.23.x, 0.24.x and 0.25.x)\
**From SQLite to PostgreSQL** (version 0.22.x,  0.23.x, 0.24.x and 0.25.x)\
**From MySQL to SQLite** (version 0.21.0 and 0.22.x, 0.23.x, 0.24.x and 0.25.x)\
\
The migration scripts are for Memos\
https://github.com/usememos/memos

The bash file is only working for certain versions. Do not try it if you have other versions.\
此Bash脚本文件只支持特定版本的数据库转换（运行脚本时请按照提示选择对应的版本），请不要在其他版本上运行。

Instruction:
1. Please run it on the test enironment first (请先在测试环境中运行)
2. The columns orders of the tables between SQLite, MySQL and PostgreSQL need to be the same (SQLite，MySQL和PostgreSQL数据库里table的column的顺序必需是一样的)
3. The database file of SQLite should be memos_prod.db (SQLite数据库文件必需为memos_prod.db)
4. The database name of MySQL and PostgreSQL can be typed in. The default is memos_prod (MySQL和PostgreSQL数据库名可自己输入，默认为memos_prod)

\
***Memos SQLite to MySQL***
1. Create the MySQL empty database with table structures before running the bash file (运行Bash脚本前请先创建好MySQL的数据库和所有table结构)\
   https://github.com/tigerzioo/memos_sqlite2mysql/issues/1 (如何创建MySQL数据库看这里、instructions for creating MySQL empty database)
2. Enter the folder where SQLite file is located (进入到SQLite数据库文件目录下)
3. Run the below command and follow the screen instruction (运行下面的命令，按照屏幕提示操作)
```
curl -sS -O https://raw.githubusercontent.com/tigerzioo/memos_sqlite2mysql/main/sqlite2mysql/memos_sqlite2mysql.sh && bash memos_sqlite2mysql.sh
```
4. Run the below command if you want to import the data manually with generated scripts（如果想用生成的导入脚本自己手动导入，可以运行下面这条命令）
```
mysql -u root -p memos_prod < memos_mysql.sql
```
\
***Memos SQLite to PostgreSQL***
1. Create the PostgreSQL empty database with table structures before running the bash file (运行Bash脚本前请先创建好PostgreSQL的数据库和所有table结构)\
   https://github.com/tigerzioo/memos_sqlite2mysql/issues/2 (如何创建PostgreSQL数据库看这里、instructions for creating PostgreSQL empty database)
2. Enter the folder where SQLite file is located (进入到SQLite数据库文件目录下)
3. The scripts will create a temp table in order to migrate the blob data. The temp table will be dropped after migration (为了导入附件数据，脚本会创建一个临时table，完成后会自动删除)
4. Run the below command and follow the screen instruction (运行下面的命令，按照屏幕提示操作)
```
curl -sS -O https://raw.githubusercontent.com/tigerzioo/memos_sqlite2mysql/main/sqlite2postgres/memos_sqlite2postgres.sh && bash memos_sqlite2postgres.sh
```
5. Run the below command if you want to import the data manually with generated scripts（如果想用生成的导入脚本自己手动导入，可以运行下面这条命令）
```
psql -d memos_prod -U root -W < memos_2post.sql
```
\
***Memos MySQL to SQLite***
1. Create the SQLite empty database file memos_prod.db before running the bash file (运行Bash脚本前请先创建好SQLite的数据库文件)
2. Enter the folder where SQLite file is located (进入到SQLite数据库文件目录下)
3. Run the below command and follow the screen instruction (运行下面的命令，按照屏幕提示操作)
```
curl -sS -O https://raw.githubusercontent.com/tigerzioo/memos_sqlite2mysql/main/mysql2sqlite/memos_mysql2sqlite.sh && bash memos_mysql2sqlite.sh
```
4. Run the below command if you want to import the data manually with generated scripts（如果想用生成的导入脚本自己手动导入，可以运行下面这条命令）
```
sqlite3 memos_prod.db < memos_2sqlite.sql
sqlite3 memos_prod.db "update memo set content=replace(content,'\\n',char(10));"
```

\
The migration does not include the below tables (数据导入导出不包含以下table，导完数据后请自行设置)\
activity\
idp\
storage\
system_setting\
user_setting\
webhook



