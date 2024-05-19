#!/bin/bash

echo " "
echo " "
echo "+++++++++++++++++ Memos MySQL 2 SQLite ++++++++++++++++++++++"
echo "提示："
echo "MySQL必需安装在本机，数据库名可自己输入，默认为memos_prod，SQLite数据库文件必需为memos_prod.db。"
echo "此Bash脚本文件要和SQLite数据库文件放在同一目录下。"
echo " "
columns=12
act=0
acts=""
v=0
vs=""
PS3="请选择SQLite导入方式："
select action in "退出" "仅生成SQLite数据库的导入脚本，稍后自己手动导入" "直接导入到SQLite数据库"
do
   # echo "选择的导入方式：$action"
   # echo "选择的序号：$REPLY"
  echo "+++++++++++++++++++"
  echo " "

  if [[ "$REPLY" == 1 ]]
  then
    echo "退出！"
    echo "+++++++++++++++++++"
    echo " "
    exit
  fi
  if [[ "$REPLY" != 2 && "$REPLY" != 3 ]]
  then
    echo "无效，请重新选择！"
  else
    act=$REPLY
    acts=$action
    break
  fi
done

PS3="请选择要转换的版本："
select ver in "0.21.0" "0.22.0"  
do
  echo "+++++++++++++++++++"
  echo " "

  if [[ "$REPLY" != 1 && "$REPLY" != 2 ]]
  then
    echo "无效，请重新选择版本！"
  else
    v=$REPLY
    vs=$ver
    break
  fi
done

echo "导入方式：$acts"
echo "版本：$vs"

while true; do
    read -p "请确认导入方式和版本，是否继续?(y/n) " yn
    case $yn in
        [Yy]* ) break;; 
        [Nn]* ) exit;;
        * ) echo "请输入 y(yes) or n(no).";;
    esac
done

read -p "请输入MySQL数据库名（回车默认为memos_prod）: " mydb
if [[ -z "$mydb" ]]; then
  mydb="memos_prod"
fi

read -p "请输入MySQL用户名（回车默认为root）: " myname
if [[ -z "$myname" ]]; then
  myname="root"
fi
echo -n "Password："
read -s mypass
if [[ -z "$mypass" ]]; then
  mypass=""
fi
echo ""
echo ""
echo "MySQL: $mydb"
echo "User: $myname"
# echo "Pass: $mypass"


# create insert scripts
# USER
mysql -u "$myname" -p"$mypass" --disable-column-names -B -e "select 'INSERT INTO user (id,created_ts,updated_ts,row_status,username,role,email,nickname,password_hash,avatar_url,description) VALUES' union all SELECT concat('(',id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',row_status,''',''',username,''',''',role,''',''',email,''',''',nickname,''',''',password_hash,''',''',avatar_url,''',''',description,'''),') as iq FROM $mydb.user" > memos_2sqlite.sql

# Replace the last comma with semi colon at the end of the file
sed -i '$ s/.$/;/' memos_2sqlite.sql

if [[ "$v" == 1 ]]
then
  # TAG
  mysqldump -u "$myname" -p"$mypass" --no-create-info --skip-triggers --compact --extended-insert=FALSE "$mydb" tag >> memos_2sqlite.sql

  # MEMO
  mysql -u "$myname" -p"$mypass" --disable-column-names -B -e "select 'INSERT INTO memo (id,uid,creator_id,created_ts,updated_ts,row_status,content,visibility) VALUES' union all SELECT concat('(',id,',''',uid,''',',creator_id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',row_status,''',''',replace(content,'''',''''''),''',''',visibility,'''),') as iq FROM $mydb.memo" >> memos_2sqlite.sql

  sed -i '$ s/.$/;/' memos_2sqlite.sql

  # RESOURCE
  if [ $(mysql -u "$myname" -p"$mypass" $mydb -sse "select count(*) from resource;") -gt 0 ];
  then
    mysql -u "$myname" -p"$mypass"  --disable-column-names -B -e "select 'INSERT INTO resource (id,uid,creator_id,created_ts,updated_ts,filename,blob,external_link,type,size,internal_path,memo_id) VALUES' union all SELECT concat('(',id,',''',uid,''',',creator_id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',filename,''',',concat('x''',hex(\`blob\`)),''',''',external_link,''',''',type,''',',size,',''',internal_path,''',',memo_id,'),') as iq FROM $mydb.resource" >> memos_2sqlite.sql

    sed -i '$ s/.$/;/' memos_2sqlite.sql
  fi
else
  # MEMO
  mysql -u "$myname" -p"$mypass" --disable-column-names -B -e "select 'INSERT INTO memo (id,uid,creator_id,created_ts,updated_ts,row_status,content,visibility,tags,payload) VALUES' union all SELECT concat('(',id,',''',uid,''',',creator_id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',row_status,''',''',replace(content,'''',''''''),''',''',visibility,''',''',tags,''',''',payload,'''),') as iq FROM $mydb.memo" >> memos_2sqlite.sql
  sed -i '$ s/.$/;/' memos_2sqlite.sql

  # RESOURCE
  if [ $(mysql -u "$myname" -p"$mypass" $mydb -sse "select count(*) from resource;") -gt 0 ];
  then
    mysql -u "$myname" -p"$mypass"  --disable-column-names -B -e "select 'INSERT INTO resource (id,uid,creator_id,created_ts,updated_ts,filename,blob,type,size,memo_id,storage_type,reference,payload) VALUES' union all SELECT concat('(',id,',''',uid,''',',creator_id,',',UNIX_TIMESTAMP(created_ts),',',UNIX_TIMESTAMP(updated_ts),',''',filename,''',',concat('x''',hex(\`blob\`)),''',''',type,''',',size,',',memo_id,',''',storage_type,''',''',reference,''',''',payload,'''),') as iq FROM $mydb.resource" >> memos_2sqlite.sql
    sed -i '$ s/.$/;/' memos_2sqlite.sql
  fi
fi

# memo_organizer
mysqldump -u "$myname" -p"$mypass" --no-create-info --skip-triggers --compact --extended-insert=FALSE "$mydb" memo_organizer >> memos_2sqlite.sql

# memo_relation
mysqldump -u "$myname" -p"$mypass" --no-create-info --skip-triggers --compact --extended-insert=FALSE "$mydb" memo_relation >> memos_2sqlite.sql

# REACTION
if [ $(mysql -u "$myname" -p"$mypass" $mydb -sse "select count(*) from reaction;") -gt 0 ];
then
  mysql -u "$myname" -p"$mypass" --disable-column-names -B -e "select 'INSERT INTO reaction (id,created_ts,creator_id,content_id,reaction_type) VALUES' union all SELECT concat('(',id,',',UNIX_TIMESTAMP(created_ts),',',creator_id,',',content_id,',''',reaction_type,'''),') as iq FROM $mydb.reaction" >> memos_2sqlite.sql

  sed -i '$ s/.$/;/' memos_2sqlite.sql
fi

# INBOX
if [ $(mysql -u "$myname" -p"$mypass" $mydb -sse "select count(*) from inbox;") -gt 0 ];
then
  mysql -u "$myname" -p"$mypass" --disable-column-names -B -e "select 'INSERT INTO inbox (id,created_ts,sender_id,receiver_id,status,message) VALUES' union all SELECT concat('(',id,',',UNIX_TIMESTAMP(created_ts),',',sender_id,',',receiver_id,',''',status,''',''',message,'''),') as iq FROM $mydb.inbox" >> memos_2sqlite.sql

  sed -i '$ s/.$/;/' memos_2sqlite.sql
fi


if [[ "$act" == 2 ]]
then
  echo " "
  echo "========脚本已生成，保存在当前目录，文件名为memos_2sqlite.sql"
  echo "+++++++++++++++++++"
  echo " "
fi

if [[ "$act" == 3 ]]
then
  # Load data to SQLite database
  sqlite3 memos_prod.db < memos_2sqlite.sql
  sqlite3 memos_prod.db "update memo set content=replace(content,'\\n',char(10));"
  sqlite3 memos_prod.db "PRAGMA wal_checkpoint(PASSIVE);" >/dev/null 2>&1 
fi
