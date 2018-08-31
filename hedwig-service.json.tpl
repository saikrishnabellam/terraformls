[
  {
    "essential": true,
    "memory": 4000,
    "name": "hedwig-services",
    "cpu": 1000,
    "image": "${REPOSITORY1_URL}:latest",

    "portMappings": [
        {
            "containerPort": 8605

        }
    ],
      "mountpoints": [
          {
             "containerpath": "/data/hedwig/Projects",
             "sourcevolume": "HEDWIG_DATA"
         },
         {
            "containerpath": "/LabShare/config.json",
            "sourcevolume": "CONFIG_DATA"
         }

     ],

     "environment": [
         {
            "name": "SQL_HOST",
            "value": "${REPOSITORY_URL}"
          },
          {
            "name": "FACEILITY_PATH",
            "value": "${facility_path}"
          }

       ]
  }


]
