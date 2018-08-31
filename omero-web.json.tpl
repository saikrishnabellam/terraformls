[
  {
    "essential": true,
    "memory": 500,
    "name": "web",
    "cpu": 500,
    "image": "labshare/omero-web-iviewer:v2018.0829.1",
    "portMappings": [
        {
            "containerPort": 4080

        }
    ],

  "environment": [
       {
          "name": "CONFIG_omero_web_session__engine",
          "value": "django.contrib.sessions.backends.cache"
       },
       {
          "name": "CONFIG_omero_web_caches",
          "value": "{\"default\": {\"BACKEND\": \"django_redis.cache.RedisCache\", \"LOCATION\": \"redis://:redis@${REPOSITORY1_URL}\"}}"
       },
       {
         "name": "CONFIG_omero_web_public_enabled",
         "value": "true"
       },
       {
         "name": "CONFIG_omero_web_public_user",
         "value": "public-user"
       },
       {
        "name": "CONFIG_omero_web_public_password",
        "value": "omero"
       },
       {
        "name": "CONFIG_omero_web_public_url__filter",
        "value": "^/(?!webadmin|webclient/(action|logout|annotate_(file|tags|comment|rating|map)|script_ui|ome_tiff|figure_script)|webgateway/(archived_files|download_as))"
       },
       {
       "name": "OMEROHOST",
       "value": "${REPOSITORY_URL}"
       }
   ]
  },
  {
    "essential": true,
    "memory": 250,
    "name": "nginx",
    "cpu": 250,
    "image": "labshare/omero-nginx",
    "portMappings": [
        {
            "containerPort": 80
        }

    ],
    "links": ["web"]
  }
]
