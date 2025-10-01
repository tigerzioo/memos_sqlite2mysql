#!/bin/bash
 
echo " "
echo " "
echo "+++++++++++++++++ Memos SQLite 2 MySQL ++++++++++++++++++++++"
echo "提示 (Note)："
echo "SQLite数据库文件必需为memos_prod.db，MySQL数据库名可自己输入，默认为memos_prod。"
echo "此Bash脚本文件要和SQLite数据库文件放在同一目录下。"
echo "The database file of SQLite should be memos_prod.db，The database name of MySQL can be typed in. The default is memos_prod。"
echo "This bash file should be in the folder where SQLite file is located。"
echo " "
columns=12
act=0
acts=""
v=0
vs=""
PS3="请选择MySQL导入方式 (Please select)："
select action in "退出 (Exit)" "仅生成MySQL数据库的导入脚本，稍后自己手动导入 (Generate the import scripts only)" "直接导入到MySQL数据库（数据库必须在本机才可以）(Import to MySQL. MySQL need to be in the same host)"
do
#  echo "选择的导入方式：$action"
#  echo "选择的序号：$REPLY"
echo "+++++++++++++++++++"
echo " "


if [[ "$REPLY" == 1 ]]
then
  echo "退出 (Exit)！"
  echo "+++++++++++++++++++"
  echo " "
  exit
fi
if [[ "$REPLY" != 2 && "$REPLY" != 3 ]]
then
  echo "无效，请重新选择 (Invalid, please select again)！"
else
  act=$REPLY
  acts=$action
  break
fi
done

PS3="请选择要转换的版本 (Select the version)："
select ver in "0.21.0" "0.22.x-0.23.x" "0.24.x-0.25.x"
do
  echo "+++++++++++++++++++"
  echo " "

  if [[ "$REPLY" != 1 && "$REPLY" != 2 && "$REPLY" != 3 ]]
  then
    echo "无效，请重新选择版本 (Invalid, please select the version)！"
  else
    v=$REPLY
    vs=$ver
    break
  fi
done

echo "导入方式 (Import option)：$acts"
echo "版本 (Version)：$vs"

while true; do
    read -p "请确认导入方式和版本，是否继续 (Please confirm)?(y/n) " yn
    case $yn in
        [Yy]* ) break;; 
        [Nn]* ) exit;;
        * ) echo "请输入 y(yes) or n(no).";;
    esac
done


# read -p "请输入SQLite数据库文件名（不填默认为memos_prod.db）(Please enter the SQLite file name. The default is memos_prod.db): " litedb
# if [[ -z "$litedb" ]]; then
  litedb="memos_prod.db"
# fi

if ! [ -f ./memos_prod.db ]; then
  echo "在当前目录下没有找到文件memos_prod.db，退出脚本 (memos_prod.db not found)。"
  echo "+++++++++++++++++++"
  echo " "
  exit
fi

sqlite3 "$litedb" ".mode insert user" "select id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,username,role,email,nickname,password_hash,avatar_url,description from user;" > memos_mysql.sql

if [[ "$v" == 1 ]]
then
  sqlite3 "$litedb" ".mode insert tag" "select name,creator_id from tag;" >> memos_mysql.sql

  sqlite3 "$litedb" ".mode insert memo" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,content,visibility FROM memo;" >> memos_mysql.sql

  sqlite3 "$litedb" ".mode insert resource" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,filename,hex(blob),external_link,type,size,internal_path,memo_id FROM resource;" >> memos_mysql.sql

elif [[ "$v" == 2 ]]
then
  sqlite3 "$litedb" ".mode insert memo" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,content,visibility,tags,payload FROM memo;" >> memos_mysql.sql

  sqlite3 "$litedb" ".mode insert resource" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,filename,hex(blob),type,size,memo_id,storage_type,reference,payload FROM resource;" >> memos_mysql.sql
else
  sqlite3 "$litedb" ".mode insert memo" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,content,visibility,pinned,payload FROM memo;" >> memos_mysql.sql

  sqlite3 "$litedb" ".mode insert resource" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,filename,hex(blob),type,size,memo_id,storage_type,reference,payload FROM resource;" >> memos_mysql.sql
fi

sqlite3 "$litedb" ".mode insert memo_organizer" "select memo_id,user_id,pinned from memo_organizer;" >> memos_mysql.sql

sqlite3 "$litedb" ".mode insert memo_relation" "select memo_id,related_memo_id,type from memo_relation;" >> memos_mysql.sql

sqlite3 "$litedb" ".mode insert reaction" "select id,datetime(created_ts, 'unixepoch') as created_ts,creator_id,content_id,reaction_type from reaction;" >> memos_mysql.sql

sqlite3 "$litedb" ".mode insert inbox" "SELECT id,datetime(created_ts, 'unixepoch') as created_ts,sender_id,receiver_id,status,message FROM inbox;" >> memos_mysql.sql

echo 'update `resource` set `blob` = unhex(`blob`) where `blob` is not null;'  >> memos_mysql.sql

if [[ "$act" == 2 ]]
then

  echo "========脚本已生成，保存在当前目录，文件名为memos_mysql.sql (The scripts generated. The file name is memos_mysql.sql)"
  echo "+++++++++++++++++++"
  echo " "
fi


if [[ "$act" == 3 ]]
then
  read -p "请输入MySQL数据库名（回车默认为memos_prod）(Please enter MySQL DB name. The default is memos_prod): " mydb
  if [[ -z "$mydb" ]]; then
    mydb="memos_prod"
  fi


  read -p "请输入MySQL用户名（回车默认为root）(Please enter the user for MySQL. The default is root): " myname
  if [[ -z "$myname" ]]; then
    myname=root
  fi
  echo "MySQL数据库 (DB): $mydb"
  echo "MySQL用户名 (user): $myname"
  mysql -u "$myname" -p "$mydb" < memos_mysql.sql
fi
