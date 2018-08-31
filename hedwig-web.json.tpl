[
  {
    "essential": true,
    "memory": 500,
    "name": "hedwig-web",
    "cpu": 500,
    "image": "${REPOSITORY1_URL}:latest",
    "portMappings": [
        {
            "containerPort": 8000

        }

    ],
      "mountpoints": [
          {
             "containerpath": "/var/www/app/app.conf",
             "sourcevolume": "APP_DATA"
         }
     ],
     "environment": [
        {
            "name": "SERVICE_URL",
            "value": "http://${REPOSITORY_URL}"
        },
        {
           "name": "FACILITY_PATH",
           "VALUE": "/"
        }
     ]
  }
]
