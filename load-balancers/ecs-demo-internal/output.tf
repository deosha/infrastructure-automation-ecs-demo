output "internal_alb_ecs-demo_tg_arn" {
  description = "arn of the internal alb target group of ecs demo"
  value       = aws_alb_target_group.ecs-demo-internal.arn
}

