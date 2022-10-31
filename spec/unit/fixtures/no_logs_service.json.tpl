[
  {
    "name": "${name}",
    "image": "${image}",
    "memory": 200,
    "essential": true,
    "command": ${command},
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ]
  }
]
