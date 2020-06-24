## LIFT and SHIFT automation code for ECS

# network directory contains automation code for network
# security-group contains automation code for security groups
# load-balancers containes automatns automation code for load balancers
# ecs contains automation code for ecs
# deployment contains automation code for deployment
# instances contain automation code for autoscxaling groups

# Each component has separate state files
# Tune parameters such as state file name, component names, sizes in autoscaling groups, docker image path etc to run your infrastructure as it is. No need to write code from scratch


#  Example Execution of Terraform Code:  
terraform plan   //will tell you difference between resource state in AWS and Resource state after you execute the script.  
terraform apply  //Will execute the script   
 
##  Separate state files are created for different components. Each component is separated at directory level.

##  To know more about terraform, visit https://www.terraform.io/
