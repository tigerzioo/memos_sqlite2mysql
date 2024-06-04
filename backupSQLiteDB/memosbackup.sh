

if [ ! -d "memosbak" ]; then
  mkdir memosbak
fi

sqlite3 memos_prod.db "PRAGMA wal_checkpoint(PASSIVE);"

cp memos_prod.db ./memosbak/"memos_prod-$(date +%Y%m%d_%H%M%S).db"

find ./memosbak -type f -mtime +30 -delete
