#!/bin/bash

REMOTE_USER="root"	#Remote UserName for mySql
REMOTE_PWD="root"	#Remote Password for mySql
REMOTE_DATABASE="NAME"	#Remote Database for mySql
REMOTE_USER_SSH="ideas2it"	#Remote UserName for ssh
REMOTE_HOST="192.168.1.145"	#Remote IP for ssh
BACKUP_DIR="/opt/backup"
NOW="$(date +%Y%m%d)";

echo "[DUMP ROUTINES]";
ssh $REMOTE_USER_SSH@$REMOTE_HOST "mysqldump -u $REMOTE_USER -p$REMOTE_PWD $REMOTE_DATABASE --routines --no-create-info --no-data --no-create-db --skip-triggers  > $BACKUP_DIR/no-portable-routines-$REMOTE_DATABASE-$NOW.sql";

echo "[DUMP DATABASE DATA]";
ssh $REMOTE_USER_SSH@$REMOTE_HOST "mysqldump -u $REMOTE_USER -p$REMOTE_PWD $REMOTE_DATABASE  > $BACKUP_DIR/no-portable-main-$REMOTE_DATABASE-$NOW.sql";

echo "[CREATE ARCHIVIE]";
ssh $REMOTE_USER_SSH@$REMOTE_HOST "zip -r -j $BACKUP_DIR/backup-$REMOTE_DATABASE-$NOW.zip $BACKUP_DIR/no-portable-routines-$REMOTE_DATABASE-$NOW.sql $BACKUP_DIR/no-portable-main-$REMOTE_DATABASE-$NOW.sql";

ssh $REMOTE_USER_SSH@$REMOTE_HOST "rm  $BACKUP_DIR/no-portable-main-$REMOTE_DATABASE-$NOW.sql"
ssh $REMOTE_USER_SSH@$REMOTE_HOST "rm  $BACKUP_DIR/no-portable-routines-$REMOTE_DATABASE-$NOW.sql"

echo "backup-$REMOTE_DATABASE-$NOW.zip"
echo "$BACKUP_DIR"
