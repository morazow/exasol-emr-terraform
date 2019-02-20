#!/usr/bin/env bash

sudo yum install -y tmux curl wget git htop

wget https://www.exasol.com/support/secure/attachment/63966/EXAplus-6.0.10.tar.gz

tar zxv --exclude='doc' -f EXAplus-6.0.10.tar.gz

mv EXAplus-6.0.10/exaplus EXAplus-6.0.10/*.jar $HOME/exaplus

rm -rf EXAplus-6.0.10*

wget http://central.maven.org/maven2/org/apache/parquet/parquet-tools/1.8.1/parquet-tools-1.8.1.jar -P $HOME/jars/
