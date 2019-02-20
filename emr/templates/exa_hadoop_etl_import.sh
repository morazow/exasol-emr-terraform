#!/usr/bin/env bash

#
# Import into Exasol Tables from Hive Tables
#
# Ensure that Hive Tables are created before running!
#

# Set exaplus executable PATH
export PATH="$HOME/exaplus:$PATH"

# Obtain master node ip (also hive metastore ip) for ETL import connection
MASTER_NODE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<-EOF > /tmp/exa-hadoop-etl-import.sql
DROP SCHEMA IF EXISTS ETL CASCADE;
CREATE SCHEMA ETL;
OPEN SCHEMA ETL;

CREATE OR REPLACE JAVA SET SCRIPT IMPORT_HCAT_TABLE(...) EMITS (...) AS
%scriptclass com.exasol.hadoop.scriptclasses.ImportHCatTable;
%jar /buckets/bfsdefault/bucket1/hadoop-etl.jar;
/

CREATE OR REPLACE JAVA SET SCRIPT IMPORT_HIVE_TABLE_FILES(...) EMITS (...) AS
%env LD_LIBRARY_PATH=/tmp/;
%scriptclass com.exasol.hadoop.scriptclasses.ImportHiveTableFiles;
%jar /buckets/bfsdefault/bucket1/hadoop-etl.jar;
/

CREATE OR REPLACE JAVA SCALAR SCRIPT HCAT_TABLE_FILES(...) EMITS (
  hdfs_server_port VARCHAR(200),
  hdfspath VARCHAR(200),
  hdfs_user_or_service_principal VARCHAR(100),
  hcat_user_or_service_principal VARCHAR(100),
  input_format VARCHAR(200),
  serde VARCHAR(200),
  column_info VARCHAR(100000),
  partition_info VARCHAR(10000),
  serde_props VARCHAR(10000),
  import_partition INT,
  auth_type VARCHAR(1000),
  conn_name VARCHAR(1000),
  output_columns VARCHAR(100000),
  enable_rpc_encryption VARCHAR(100),
  debug_address VARCHAR(200))
AS
%scriptclass com.exasol.hadoop.scriptclasses.HCatTableFiles;
%jar /buckets/bfsdefault/bucket1/hadoop-etl.jar;
/

DROP SCHEMA IF EXISTS HADOOP_RETAIL CASCADE;
CREATE SCHEMA HADOOP_RETAIL;
OPEN SCHEMA HADOOP_RETAIL;

DROP TABLE IF EXISTS SALES_POSITIONS;

CREATE TABLE SALES_POSITIONS (
  SALES_ID    INTEGER,
  POSITION_ID SMALLINT,
  ARTICLE_ID  SMALLINT,
  AMOUNT      SMALLINT,
  PRICE       DECIMAL(9,2),
  VOUCHER_ID  SMALLINT,
  CANCELED    BOOLEAN
);

DROP TABLE IF EXISTS SALES;

CREATE TABLE SALES (
  SALES_ID                INTEGER,
  SALES_DATE              DATE,
  SALES_TIMESTAMP         TIMESTAMP,
  PRICE                   DECIMAL(9,2),
  MONEY_GIVEN             DECIMAL(9,2),
  RETURNED_CHANGE         DECIMAL(9,2),
  LOYALTY_ID              INTEGER,
  MARKET_ID               SMALLINT,
  TERMINAL_ID             SMALLINT,
  EMPLOYEE_ID             SMALLINT,
  TERMINAL_DAILY_SALES_NR SMALLINT
);

-- ALTER SESSION SET SCRIPT_OUTPUT_ADDRESS='$MASTER_NODE_IP:3000';

IMPORT INTO HADOOP_RETAIL.SALES_POSITIONS
FROM SCRIPT ETL.IMPORT_HCAT_TABLE WITH
  HCAT_DB         = 'default'
  HCAT_TABLE      = 'sales_positions'
  HCAT_ADDRESS    = 'thrift://$MASTER_NODE_IP:9083'
  HCAT_USER       = 'hive'
  HDFS_USER       = 'hdfs'
  PARALLELISM     = 'nproc()*4';

SELECT * FROM HADOOP_RETAIL.SALES_POSITIONS LIMIT 10;

IMPORT INTO HADOOP_RETAIL.SALES
FROM SCRIPT ETL.IMPORT_HCAT_TABLE WITH
  HCAT_DB         = 'default'
  HCAT_TABLE      = 'sales'
  HCAT_ADDRESS    = 'thrift://$MASTER_NODE_IP:9083'
  HCAT_USER       = 'hive'
  HDFS_USER       = 'hdfs'
  PARALLELISM     = 'nproc()*4';

SELECT * FROM HADOOP_RETAIL.SALES LIMIT 10;
EOF

exaplus -c 10.0.0.11:8563 -u sys -P ${exa_password} -f /tmp/exa-hadoop-etl-import.sql
