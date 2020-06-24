output "external_alb_ext_tg_arn" {
  description = "arn of the external alb target group of ecs=demo-nginx"
  value       = aws_alb_target_group.this.arn
}

