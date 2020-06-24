[
  {
    "name": "ecs-demo-prod",
    "image": "xxxxxxxx.dkr.ecr.ap-south-1.amazonaws.com/ecs-demo:${tag}",
    "memory": 512,
    "portMappings": [
      {
        "hostPort": 0,
        "containerPort": 8080,
        "protocol": "tcp"
      }
    ],
   "logConfiguration": {
      "logDriver": "awslogs",
       "options": {
                    "awslogs-group": "ecs-demo-prod",
                    "awslogs-region": "ap-south-1",
                    "awslogs-stream-prefix": "ecs-demo-prod"
                }
    }
   
   }
]
