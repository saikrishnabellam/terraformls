[
  {
    "essential": true,
    "memory": 4000,
    "name": "omero-master",
    "cpu": 1000,
    "image": "labshare/omero-cloudserver:v2018.0830.1",
    "mountpoints": [
        {
           "containerpath": "/OMERO",
           "sourcevolume": "OMERO_DATA"
         }
       ],
    "portMappings": [
        {
            "containerPort": 4063,
            "hostPort": 4063
        },
        {
            "containerPort": 4064,
            "hostPort": 4064
        }

    ],
    "environment":[
      {
        "name": "CONFIG_omero_db_name",
        "value": "postgres"
      },

      {
        "name": "CONFIG_omero_db_pass",
        "value": "postgres"

      },
      {
        "name": "CONFIG_omero_db_user",
        "value": "postgres"
      },
      {
        "name": "CONFIG_omero_web_public_enabled",
        "value": "true"
      },
      {
        "name": "ROOTPASS",
        "value": "omero"
      },
      {
        "name": "CONFIG_omero_db_host",
        "value": "${REPOSITORY_URL}"
      }
    ]

  }
]
