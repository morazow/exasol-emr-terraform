#!/usr/bin/env bash

# Set exaplus executable PATH
export PATH="$HOME/exaplus:$PATH"

# Obtain master node ip (also hive metastore ip) for ETL import connection
MASTER_NODE_IP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<-EOF > /tmp/exa-s3-etl.sql
DROP SCHEMA IF EXISTS S3ETL CASCADE;
CREATE SCHEMA S3ETL;
OPEN SCHEMA S3ETL;

CREATE OR REPLACE JAVA SET SCRIPT IMPORT_S3_PATH(...) EMITS (...) AS
%scriptclass com.exasol.s3etl.scriptclasses.ImportS3Path;
%jar /buckets/bfsdefault/bucket1/s3-etl.jar;
/

CREATE OR REPLACE JAVA SET SCRIPT IMPORT_S3_FILES(...) EMITS (...) AS
%env LD_LIBRARY_PATH=/tmp/;
%scriptclass com.exasol.s3etl.scriptclasses.ImportS3Files;
%jar /buckets/bfsdefault/bucket1/s3-etl.jar;
/

CREATE OR REPLACE JAVA SCALAR SCRIPT IMPORT_S3_METADATA(...)
EMITS (s3_filename VARCHAR(200), partition_index VARCHAR(100)) AS
%scriptclass com.exasol.s3etl.scriptclasses.ImportS3Metadata;
%jar /buckets/bfsdefault/bucket1/s3-etl.jar;
/


DROP SCHEMA IF EXISTS S3_RETAIL CASCADE;
CREATE SCHEMA S3_RETAIL;
OPEN SCHEMA S3_RETAIL;

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

IMPORT INTO SALES_POSITIONS
FROM SCRIPT S3ETL.IMPORT_S3_PATH WITH
  S3_BUCKET_PATH = 's3a://exa-mo-frankfurt/retail_parquet/sales_positions/*'
  S3_ACCESS_KEY  = '${aws_access_key}'
  S3_SECRET_KEY  = '${aws_secret_key}'
  PARALLELISM    = 'nproc()*10';


IMPORT INTO SALES
FROM SCRIPT S3ETL.IMPORT_S3_PATH WITH
  S3_BUCKET_PATH = 's3a://exa-mo-frankfurt/retail_parquet/sales/*'
  S3_ACCESS_KEY  = '${aws_access_key}'
  S3_SECRET_KEY  = '${aws_secret_key}'
  PARALLELISM    = 'nproc()*10';

SELECT * FROM SALES_POSITIONS LIMIT 10;
SELECT * FROM SALES LIMIT 10;
EOF

exaplus -c 10.0.0.11:8563 -u sys -P ${exa_password} -f /tmp/exa-s3-etl.sql
