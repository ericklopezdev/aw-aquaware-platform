project_name = "aw-bootcamp"
aws_region   = "us-east-1"
vpc_cidr     = "10.0.0.0/16"
public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
private_subnets = [
  "10.0.101.0/24",
  "10.0.102.0/24"
]
availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

node_instance_type = "t3.small"
node_count         = 1

tags = {
  "project" = "aw-bootcamp"
  "env"     = "sandbox"
}
