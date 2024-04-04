#!/bin/bash

echo " "
echo " "
echo "+++++++++++++++++ Memos SQLite 2 MySQL ++++++++++++++++++++++"
echo "提示："
echo "SQLite数据库文件必需为memos_prod.db，MySQL数据库名必需为memos_prod。"
echo "此Bash脚本文件要和SQLite数据库文件放在同一目录下。"
echo " "
columns=12
PS3="请选择MySQL导入方式："
select action in "退出" "仅生成MySQL数据库的导入脚本，稍后自己手动导入" "直接导入到MySQL数据库（数据库必须在本机才可以）"
do
#  echo "选择的导入方式：$action"
#  echo "选择的序号：$REPLY"
echo "+++++++++++++++++++"
echo " "


if [[ "$REPLY" == 1 ]]
then
  echo "退出！"
  exit
fi
if [[ "$REPLY" != 2 && "$REPLY" != 3 ]]
then
  echo "无效，请重新选择！"
else
  break
fi

done


sqlite3 memos_prod.db ".mode insert user" "select id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,username,role,email,nickname,password_hash,avatar_url,description from user;" > memos_mysql.sql

sqlite3 memos_prod.db ".mode insert tag" "select name,creator_id from tag;" >> memos_mysql.sql

sqlite3 memos_prod.db ".mode insert memo" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,row_status,content,visibility FROM memo;" >> memos_mysql.sql

sqlite3 memos_prod.db ".mode insert resource" "SELECT id,uid,creator_id,datetime(created_ts, 'unixepoch') as created_ts,datetime(updated_ts, 'unixepoch') as updated_ts,filename,hex(blob),external_link,type,size,internal_path,memo_id FROM resource;" >> memos_mysql.sql

sqlite3 memos_prod.db ".mode insert memo_organizer" "select memo_id,user_id,pinned from memo_organizer;" >> memos_mysql.sql

sqlite3 memos_prod.db ".mode insert memo_relation" "select memo_id,related_memo_id,type from memo_relation;" >> memos_mysql.sql

sqlite3 memos_prod.db ".mode insert reaction" "select id,datetime(created_ts, 'unixepoch') as created_ts,creator_id,content_id,reaction_type from reaction;" >> memos_mysql.sql

sqlite3 memos_prod.db ".mode insert inbox" "SELECT id,datetime(created_ts, 'unixepoch') as created_ts,sender_id,receiver_id,status,message FROM inbox;" >> memos_mysql.sql


if [[ "$REPLY" == 2 ]]
then

  echo "========脚本已生成，保存在当前目录，文件名为memos_mysql.sql"
  echo " "
fi


if [[ "$REPLY" == 3 ]]
then
  read -p "请输入MySQL用户名（不填默认为root）: " myname
  if [[ -z "$myname" ]]; then
    myname=root
  fi
  mysql -u "$myname" -p memos_prod < memos_mysql.sql
fi
