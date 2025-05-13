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
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}",
        "awslogs-stream-prefix": "prefix"
      }
    }
  }
]
