#!/usr/bin/env bash

# Set exaplus executable PATH
export PATH="$HOME/exaplus:$PATH"

# Obtain master node ip (also hive metastore ip) for ETL import connection
MASTER_NODE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<-EOF > /tmp/exa-cloud-etl-import.sql
DROP SCHEMA IF EXISTS ETL CASCADE;
CREATE SCHEMA ETL;
OPEN SCHEMA ETL;

CREATE OR REPLACE JAVA SET SCRIPT IMPORT_PATH(...) EMITS (...) AS
%scriptclass com.exasol.cloudetl.scriptclasses.ImportPath;
%jar /buckets/bfsdefault/bucket1/cloud-etl.jar;
/

CREATE OR REPLACE JAVA SET SCRIPT IMPORT_FILES(...) EMITS (...) AS
%env LD_LIBRARY_PATH=/tmp/;
%scriptclass com.exasol.cloudetl.scriptclasses.ImportFiles;
%jar /buckets/bfsdefault/bucket1/cloud-etl.jar;
/

CREATE OR REPLACE JAVA SCALAR SCRIPT IMPORT_METADATA(...)
EMITS (filename VARCHAR(200), partition_index VARCHAR(100)) AS
%scriptclass com.exasol.cloudetl.scriptclasses.ImportMetadata;
%jar /buckets/bfsdefault/bucket1/cloud-etl.jar;
/

-- ALTER SESSION SET SCRIPT_OUTPUT_ADDRESS='$MASTER_NODE_IP:3000';

DROP SCHEMA IF EXISTS CLOUD_RETAIL CASCADE;
CREATE SCHEMA CLOUD_RETAIL;
OPEN SCHEMA CLOUD_RETAIL;

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

IMPORT INTO CLOUD_RETAIL.SALES_POSITIONS
FROM SCRIPT ETL.IMPORT_PATH WITH
  BUCKET_PATH    = 's3a://exa-mo-frankfurt/retail_parquet/sales_positions/*'
  S3_ACCESS_KEY  = '${aws_access_key}'
  S3_SECRET_KEY  = '${aws_secret_key}'
  S3_ENDPOINT    = 's3.eu-central-1.amazonaws.com'
  PARALLELISM    = 'nproc()*4';

SELECT * FROM CLOUD_RETAIL.SALES_POSITIONS LIMIT 10;

IMPORT INTO CLOUD_RETAIL.SALES
FROM SCRIPT ETL.IMPORT_PATH WITH
  BUCKET_PATH    = 's3a://exa-mo-frankfurt/retail_parquet/sales/*'
  S3_ACCESS_KEY  = '${aws_access_key}'
  S3_SECRET_KEY  = '${aws_secret_key}'
  S3_ENDPOINT    = 's3.eu-central-1.amazonaws.com'
  PARALLELISM    = 'nproc()*4';

SELECT * FROM CLOUD_RETAIL.SALES LIMIT 10;
EOF

exaplus -c 10.0.0.11:8563 -u sys -P ${exa_password} -f /tmp/exa-cloud-etl-import.sql
