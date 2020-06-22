output "ssh_security_group_id" {
  description = "The ID of the ssh security group"
  value       = module.ssh_sg.this_security_group_id
}

output "public_alb_security_group_id" {
  description = "The ID of the public alb security group"
  value       = module.public_alb_sg.this_security_group_id
}

output "internal_alb_security_group_id" {
  description = "The ID of the internal security group"
  value       = module.internal_alb_sg.this_security_group_id
}

output "bastion_security_group_id" {
  description = "The ID of the bastion security group"
  value       = module.bastion_sg.this_security_group_id
}
