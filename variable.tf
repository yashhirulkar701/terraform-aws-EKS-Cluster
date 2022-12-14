variable "vpc_cidr" {
  description = "cidr for vpc"
  type        = string
  default     = "10.0.0.0/16"
}

variable "sub_count" {
  description = "required subnet count"
  type        = number
  default     = 3
}

variable "cluster_version" {
  description = "required cluster version"
  type        = number
  default     = 1.23
}

variable "node_group_count" {
  description = "required node group count"
  type        = number
  default     = 2
}

variable "eks_instance_type" {
  description = "required instance type"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "required disk size"
  type        = number
  default     = 20
}

variable "desired_vm_size" {
  description = "required virtual machine count"
  type        = number
  default     = 2
}

variable "max_vm_size" {
  description = "maximum required virtual machine count"
  type        = number
  default     = 3
}

variable "min_vm_size" {
  description = "minimum required virtual machine count"
  type        = number
  default     = 1
}

variable "max_vm_unavailable" {
  description = "maximum unavailable virtual machine count"
  type        = number
  default     = 1
}

variable "logs_retention_days" {
  description = "number of days to retain the logs"
  type        = number
  default     = 1
}

variable "sg_rules" {
  description = "values for each security group rule"
  type = list(object({
    description = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      description = "Allow inbound traffic for ssh"
      cidr_blocks = ["10.0.0.0/8"]
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    }
  ]
}