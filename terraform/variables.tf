variable "aws_region" {
  description = "AWS region the cluster and its VPC live in."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used to namespace tags."
  type        = string
  default     = "job-board-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS managed node group."
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes. Kept small on purpose — this is a teaching cluster, not a production sizing exercise."
  type        = number
  default     = 2
}
