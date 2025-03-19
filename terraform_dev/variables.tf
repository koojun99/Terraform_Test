variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "vpc_main_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "server_port" {
  type = number
  default = 80
}

variable "my_ip" {
  type = string
  default = "0.0.0.0/0"
}

variable "alb_security_group_name" {
  type = string
  default = "alb-SG"
}

variable "alb_name" {
  type = string
  default = "webserver-ALB"
}