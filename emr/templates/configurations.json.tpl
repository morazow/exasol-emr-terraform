[
  {
    "Classification": "spark-defaults",
    "Properties": {
      "maximizeResourceAllocation": "true",
      "spark.dynamicAllocation.enabled" : "false",
      "spark.serializer" : "org.apache.spark.serializer.KryoSerializer"
    }
  },
  {
    "Classification": "spark",
    "Properties": {
      "maximizeResourceAllocation": "true",
      "spark.dynamicAllocation.enabled" : "false",
      "spark.serializer" : "org.apache.spark.serializer.KryoSerializer"
    }
  },
  {
    "Classification": "zeppelin-env",
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "SPARK_SUBMIT_OPTIONS": "\"$SPARK_SUBMIT_OPTIONS --conf 'spark.executorEnv.PYTHONPATH=/usr/lib/spark/python/lib/py4j-src.zip:/usr/lib/spark/python/:<CPS>{{PWD}}/pyspark.zip<CPS>{{PWD}}/py4j-src.zip' --conf spark.yarn.isPython=true --jars ${spark_exasol_connector_jar}\""
        },
        "Configurations": []
      }
    ]
  }
]
