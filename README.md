# **MySQL Backup and Recovery**


#### Backup and Recovery Types

##### Physical (Raw) Backups :
 - Physical backups consist of raw copies of the directories and files that store database contents. This type of backup is suitable for large.
- Physical backup tools include the **mysqlbackup** of **MySQL** Enterprise Backup for  **InnoDB** or any other tables, file system-level commands **(such as cp, scp, tar, rsync)**  or  **mysqlhotcopy**  for **MyISAM** tables.

#### Logical Backups :
 - Logical backups save information represented as logical database structure **(CREATE DATABASE, CREATE TABLE statements)** and content **(INSERT statements or delimited-text files)**.
 - This type of  backup is suitable for smaller amounts of data where you might edit the data values or table structure, or recreate the data on a different machine architecture.
 - Output is larger than for physical backup, particularly when saved in text format.
 - Backups stored in logical format are machine independent and highly portable.
 - Logical backups are performed with the **MySQL** server running. The server is not taken offline.
 - Logical backup tools include the mysqldump program and the **SELECT ... INTO OUTFILE**
 - These work for any storage engine, even MEMORY.
 - To restore logical backups, SQL-format dump files can be processed using the mysql client. To load delimited-text files, use the **LOAD DATA INFILE** statement or the mysqlimport client.

## Online Versus Offline Backups

### Online backups

- It take place while the **MySQL** server is running so that the database information can be obtained from the server.
- Care must be taken to impose appropriate locking so that data modifications do not take place that would compromise backup integrity. The **MySQL** Enterprise Backup product does such locking automatically.

### Offline backups:
- It take place while the server is stopped. This distinction can also be described as “hot” versus “cold” backups; a “warm” backup is one where the server remains running but locked against modifying data while you access database files externally.
- Clients can be affected adversely because the server is unavailable during backup. For that reason, such backups are often taken from a replication slave server that can be taken offline without harming availability.
- The backup procedure is simpler because there is no possibility of interference from client activity.


## Local Versus Remote Backups

- A local backup is performed on the same host where the **MySQL** server runs, whereas a remote backup  is done from a different host. For some types of backups, the backup can be initiated from a remote host even if the output is written locally on the server.
- **mysqldump** can connect to local or remote servers. For SQL output  **(CREATE and INSERT statements)**, local or remote dumps can be done and generate output on the client. For delimited-text output (with the --tab option), data files are created on the server host.
- **mysqlhotcopy** performs only local backups: It connects to the server to lock it against data modifications and then copies local table files.
- **SELECT ... INTO OUTFILE** can be initiated from a local or remote client host, but the output file is created on the server host. Physical backup methods typically are initiated locally on the **MySQL** server  host so that the server can be taken offline, although the destination for copied files might be remote.

## Snapshot Backups

 - Some file system implementations enable “snapshots” to be taken. These provide logical copies of the file system at a given point in time, without requiring a physical copy of the entire file system

## Full Versus Incremental Backups
```
 # TODO
```

### Dumping Data in SQL Format with mysqldump

```
mysqldump [arguments] > file_name
```
To dump all databases, invoke mysqldump with the --all-databases option:
```
mysqldump --all-databases > dump.sql
```
To dump only specific databases:
```
mysqldump --databases db1 db2 db3 > dump.sql
```
To dump a single database, name it on the command line:
```
mysqldump --databases test > dump.sql
mysqldump test > dump.sql
```

To dump only specific tables from a database, name them on the command line
following the database name:
```
mysqldump test t1 t3 t7 > dump.sql
```

 mysqldump has options to export schema and data separately:
```
# Export schema
mysqldump --no-data sakila > schema.sql
# Export data
mysqldump --no-create-info --skip-triggers sakila > data.sql
```

## **MySQL** Dump Full Structure, Partial Data, With Triggers & Routines.
### A better way:

- Schema first
- Data next
- Triggers and routines last

```
mysqldump --no-data --skip-triggers DATABASE > FILE.sql
mysqldump --no-create-db --no-create-info --skip-triggers --ignore-table=TABLE1--ignore-table=TABLE2 DATABASE >> FILE.sql
mysqldump --no-create-db --no-create-info --no-data  --routines --triggers --skip-opt DATABASE >> FILE.sql
```
# Remote script for taking  Dump  from server [mysqldumpscript][mysqldumpscript]

mysqldump will backup by default all the triggers but NOT the stored procedures/functions. There are 2 mysqldump parameters that control this behavior:

- --routines : FALSE by default
- --triggers : TRUE by default

This means that if you want to include in an existing backup script also the triggers and stored procedures you only need to add the —routines command line parameter:
```
mysqldump <other mysqldump options> --routines outputfile.sql
```
Let’s assume we want to backup ONLY the stored procedures and triggers and not the mysql tables and data (this can be useful to import these in another db/server that has already the data but not the stored procedures and/or triggers), then we should run something like:
```
mysqldump --routines --no-create-info --no-data --no-create-db --skip-opt <database> > outputfile.sql
```
and this will save only the procedures/functions/triggers of the . If you need to import them to another db/server you will have to run something like:
```
mysql <database> < outputfile.sql
```


  [mysqldumpscript]: https://github.com/mohankumarideas2it/mysqldump/blob/master/export-database.sh "mysqldumpscript"
