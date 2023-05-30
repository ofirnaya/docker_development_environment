#!/bin/sh


cd /home/developer/

sudo HADOOP_USER_NAME=hdfs PYSPARK_PYTHON=python3 PYSPARK_DRIVER_PYTHON=python3 -u developer /usr/local/bin/jupyter lab
