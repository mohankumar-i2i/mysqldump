#!/bin/bash

LOCAL_USER='root'	#Restore UserName for mySql
LOCAL_PWD='root' 	#Restore Password for mySql
LOCAL_DATABASE='NAME'	#Restore Database for mySql
BACKUP_DIR='/opt/backup'
FILE_NAME='backup-NAME-20170328.zip' #backfilezip


IFS='.' read -r -a DB_FILENAME <<< "$FILE_NAME"
IFS='-' read -r -a DB_FILENAME <<< "${DB_FILENAME[0]}"
DB_FILENAME="${DB_FILENAME[1]}-${DB_FILENAME[2]}"
cd $BACKUP_DIR
ls -1 *.zip
if [  $? -eq 0 ]
then
    unzip -t $BACKUP_DIR/$FILE_NAME
    if [ $? -eq 0 ]
    then
        unzip  $BACKUP_DIR/$FILE_NAME
        for i in $(zipinfo -1 $BACKUP_DIR/$FILE_NAME); do
          if [[ $i == *"routines"* ]]; then
            sed -E 's/DEFINER=`[^`]+`@`[^`]+`/ /g' $BACKUP_DIR/$i > $BACKUP_DIR/routines-$DB_FILENAME.sql
          fi
          if [[ $i == *"main"* ]]; then
            sed -E 's/DEFINER=`[^`]+`@`[^`]+`/ /g' $BACKUP_DIR/$i > $BACKUP_DIR/main-$DB_FILENAME.sql
          fi
        done
    else
       echo 'Files does not exists or zip corrupted'
       exit
    fi
else
    echo 'Folder not contain in zip files'
    exit
fi

echo "[DROP OLD DATABASE]";
eval "mysql -u $LOCAL_USER -p$LOCAL_PWD -e 'SET FOREIGN_KEY_CHECKS=0;DROP DATABASE IF EXISTS $LOCAL_DATABASE;SET FOREIGN_KEY_CHECKS=1;'"
eval "mysql -u $LOCAL_USER -p$LOCAL_PWD -e 'CREATE DATABASE $LOCAL_DATABASE CHARACTER SET utf8 COLLATE utf8_general_ci'"

echo "[RESTORE ROUTINES]";
mysql -u $LOCAL_USER -p$LOCAL_PWD $LOCAL_DATABASE < $BACKUP_DIR/routines-$DB_FILENAME.sql
echo "[RESTORE DATABASE]";
mysql -u $LOCAL_USER -p$LOCAL_PWD $LOCAL_DATABASE < $BACKUP_DIR/main-$DB_FILENAME.sql
rm -rf $BACKUP_DIR/*.sql
echo "[RESTORE DATABASE COMPLETED]";
