variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "sub_count" {
  type    = number
  default = 3
}

variable "cluster_version" {
  type    = number
  default = 1.23
}

variable "node_group_count" {
  type    = number
  default = 2
}

variable "eks_instance_type" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_vm_size" {
  type    = number
  default = 2
}

variable "max_vm_size" {
  type    = number
  default = 3
}

variable "min_vm_size" {
  type    = number
  default = 1
}

variable "max_vm_unavailable" {
  type    = number
  default = 1
}

variable "sg_rules" {
  description = "values for each nsg rule"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = [
    {
      description = "for ssh"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
    },
    {
      description = "for http"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
    }
  ]
}