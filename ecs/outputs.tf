output "cluster_name" {
  description = "ecs cluster name"
  value       = module.ecs.this_ecs_cluster_name
}

output "iam_instance_profile_id" {
  description = "ec2 iam profile id"
  value       = module.ec2-profile.this_iam_instance_profile_id
}

output "cluster_id" {
  description = "ecs cluster id"
  value = module.ecs.this_ecs_cluster_id
}
